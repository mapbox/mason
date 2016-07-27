string(RANDOM LENGTH 16 MASON_INVOCATION)

function(mason_use _PACKAGE)
    if(NOT _PACKAGE)
        message(FATAL_ERROR "[Mason] No package name given")
    endif()

    cmake_parse_arguments("" "HEADER_ONLY" "VERSION" "" ${ARGN})

    if(_UNPARSED_ARGUMENTS)
        message(FATAL_ERROR "[Mason] mason_use() called with unrecognized arguments: ${_UNPARSED_ARGUMENTS}")
    endif()

    if(NOT _VERSION)
        message(FATAL_ERROR "[Mason] Specifying a version is required")
    endif()

    if(NOT MASON_PLATFORM OR NOT MASON_PLATFORM_VERSION)
        message(FATAL_ERROR "[Mason] Please set MASON_PLATFORM and MASON_PLATFORM_VERSION")
    endif()

    # URL prefix of where packages are located.
    if (MASON_REPOSITORY)
        set(_mason_repository "${MASON_REPOSITORY}")
    else()
        set(_mason_repository "https://mason-binaries.s3.amazonaws.com")
    endif()

    # Directory where Mason packages are located; typically ends with mason_packages
    if (MASON_PACKAGE_DIR)
        set(_PACKAGE_DIR "${MASON_PACKAGE_DIR}")
    else()
        set(_PACKAGE_DIR "${CMAKE_SOURCE_DIR}/mason_packages")
    endif()

    # Path to Mason executable
    if (MASON_COMMAND)
        set(_COMMAND "${MASON_COMMAND}")
    else()
        set(_COMMAND "${CMAKE_SOURCE_DIR}/.mason/mason")
    endif()

    if(MASON_${_PACKAGE}_INVOCATION STREQUAL "${MASON_INVOCATION}")
        # Check that the previous invocation of mason_use didn't select another version of this package
        if(NOT MASON_${_PACKAGE}_VERSION STREQUAL ${_VERSION})
            message(FATAL_ERROR "[Mason] Already using ${_PACKAGE} ${MASON_${_PACKAGE}_VERSION}. Cannot select version ${_VERSION}.")
        endif()
    else()
        if(_HEADER_ONLY)
            set(_PLATFORM_ID "headers")
        else()
            set(_PLATFORM_ID "${MASON_PLATFORM}-${MASON_PLATFORM_VERSION}")
        endif()

        set(_SLUG "${_PLATFORM_ID}/${_PACKAGE}/${_VERSION}")
        set(_INSTALL_PATH "${_PACKAGE_DIR}/${_SLUG}")
        file(RELATIVE_PATH _INSTALL_PATH_RELATIVE "${CMAKE_CURRENT_SOURCE_DIR}" "${_INSTALL_PATH}")

        if(NOT EXISTS "${_INSTALL_PATH}")
            set(_CACHE_PATH "${_PACKAGE_DIR}/.binaries/${_SLUG}.tar.gz")
            if (NOT EXISTS "${_CACHE_PATH}")
                # Download the package
                set(_URL "${_mason_repository}/${_SLUG}.tar.gz")
                message(STATUS "[Mason] Downloading package ${_URL}...")
                file(DOWNLOAD "${_URL}" "${_CACHE_PATH}.tmp" STATUS result TLS_VERIFY ON)
                list(GET result 0 status)
                if(status)
                    list(GET result 1 message)
                    message(FATAL_ERROR "[Mason] Failed to download ${_URL}: ${message}")
                else()
                    # We downloaded to a temporary file to prevent half-finished downloads
                    file(RENAME "${_CACHE_PATH}.tmp" "${_CACHE_PATH}")
                endif()
            endif()

            # Unpack the package
            message(STATUS "[Mason] Unpacking package to ${_INSTALL_PATH_RELATIVE}...")
            file(MAKE_DIRECTORY "${_INSTALL_PATH}")
            execute_process(COMMAND ${CMAKE_COMMAND} -E tar xzf "${_CACHE_PATH}" WORKING_DIRECTORY "${_INSTALL_PATH}")
        endif()

        # Create a config file if it doesn't exist in the package
        # TODO: remove this once all packages have a mason.ini file
        if(NOT EXISTS "${_INSTALL_PATH}/mason.ini")
            # Change pkg-config files
            file(GLOB_RECURSE _PKGCONFIG_FILES "${_INSTALL_PATH}/*.pc")
            foreach(_PKGCONFIG_FILE IN ITEMS ${_PKGCONFIG_FILES})
                file(READ "${_PKGCONFIG_FILE}" _PKGCONFIG_FILE_CONTENT)
                string(REGEX REPLACE "^prefix=[^\n]*" "prefix=${_INSTALL_PATH}" _PKGCONFIG_FILE_CONTENT "${_PKGCONFIG_FILE_CONTENT}")
                file(WRITE "${_PKGCONFIG_FILE}" "${_PKGCONFIG_FILE_CONTENT}")
            endforeach()

            set(_FAILED)
            set(_ERROR)
            execute_process(
                COMMAND ${_COMMAND} config ${_PACKAGE} ${_VERSION}
                WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
                OUTPUT_FILE "${_INSTALL_PATH}/mason.ini"
                RESULT_VARIABLE _FAILED
                ERROR_VARIABLE _ERROR)
            if(_FAILED)
                message(FATAL_ERROR "[Mason] Could not get configuration for package ${_PACKAGE} ${_VERSION}: ${_ERROR}")
            endif()
        endif()

        # Load the configuration from the ini file
        file(STRINGS "${_INSTALL_PATH}/mason.ini" _CONFIG_FILE)
        foreach(_LINE IN LISTS _CONFIG_FILE)
            string(REGEX MATCH "^([a-z_]+) *= *" _KEY "${_LINE}")
            if (_KEY)
                string(LENGTH "${_KEY}" _KEY_LENGTH)
                string(SUBSTRING "${_LINE}" ${_KEY_LENGTH} -1 _VALUE)
                string(REGEX REPLACE ";.*$" "" _VALUE "${_VALUE}") # Trim trailing commas
                string(REPLACE "{prefix}" "${_INSTALL_PATH}" _VALUE "${_VALUE}")
                string(STRIP "${_VALUE}" _VALUE)
                string(REPLACE "=" "" _KEY "${_KEY}")
                string(TOUPPER "${_KEY}" _KEY)
                set(MASON_CONFIG_${_PACKAGE}_${_KEY} "${_VALUE}" CACHE STRING "${_PACKAGE} ${_KEY}" FORCE)
            endif()
        endforeach()

        # Compare version in the package to catch errors early on
        if(NOT _VERSION STREQUAL MASON_CONFIG_${_PACKAGE}_VERSION)
            message(FATAL_ERROR "[Mason] Package at ${_INSTALL_PATH_RELATIVE} has version '${MASON_CONFIG_${_PACKAGE}_VERSION}', but required version '${_VERSION}'")
        endif()

        # Concatenate the static libs and libraries
        set(libraries)
        list(APPEND libraries ${MASON_CONFIG_${_PACKAGE}_STATIC_LIBS} ${MASON_CONFIG_${_PACKAGE}_LDFLAGS})
        set(MASON_CONFIG_${_PACKAGE}_LIBRARIES "${libraries}" CACHE STRING "${_PACKAGE} libraries" FORCE)

        # Store invocation ID to prevent different versions of the same package in one invocation
        set(MASON_CONFIG_${_PACKAGE}_INVOCATION "${MASON_INVOCATION}" CACHE INTERNAL "${_PACKAGE} invocation ID" FORCE)

        message(STATUS "MASON_CONFIG_${_PACKAGE}_INCLUDE_DIRS: ${MASON_CONFIG_${_PACKAGE}_INCLUDE_DIRS}")
        message(STATUS "MASON_CONFIG_${_PACKAGE}_DEFINITIONS: ${MASON_CONFIG_${_PACKAGE}_DEFINITIONS}")
        message(STATUS "MASON_CONFIG_${_PACKAGE}_OPTIONS: ${MASON_CONFIG_${_PACKAGE}_OPTIONS}")
        message(STATUS "MASON_CONFIG_${_PACKAGE}_LIBRARIES: ${MASON_CONFIG_${_PACKAGE}_LIBRARIES}")
    endif()
endfunction()

macro(target_add_mason_package _TARGET _VISIBILITY _PACKAGE)
    mason_use("${_PACKAGE}" "${MASON_CONFIG_${_PACKAGE}_VERSION}")
    target_include_directories(${_TARGET} ${_VISIBILITY} "${MASON_CONFIG_${_PACKAGE}_INCLUDE_DIRS}")
    target_compile_definitions(${_TARGET} ${_VISIBILITY} "${MASON_CONFIG_${_PACKAGE}_DEFINITIONS}")
    target_compile_options(${_TARGET} ${_VISIBILITY} "${MASON_CONFIG_${_PACKAGE}_OPTIONS}")
    target_link_libraries(${_TARGET} ${_VISIBILITY} "${MASON_CONFIG_${_PACKAGE}_LIBRARIES}")
endmacro()
