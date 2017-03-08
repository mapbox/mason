source mason.sh

mason_use --header-only header-only.hpp 4.2

# Check file existence
mason_succeeds "cached tarball" [ -f "mason_packages/.binaries/headers/header-only.hpp/4.2.tar.gz" ]
mason_succeeds "install folder" [ -d "mason_packages/headers/header-only.hpp/4.2" ]
mason_succeeds "unpacked ini file" [ -f "mason_packages/headers/header-only.hpp/4.2/mason.ini" ]
mason_succeeds "unpacked header file" [ -f "mason_packages/headers/header-only.hpp/4.2/include/header.h" ]

# Get arguments
mason_succeeds "get PREFIX" [ "${MASON_PACKAGE_header_only_hpp_PREFIX}" = "`pwd`/mason_packages/headers/header-only.hpp/4.2" ]
mason_succeeds "get NAME" [ "${MASON_PACKAGE_header_only_hpp_NAME}" = "header-only.hpp" ]
mason_succeeds "get VERSION" [ "${MASON_PACKAGE_header_only_hpp_VERSION}" = "4.2" ]
mason_succeeds "get PLATFORM" [ -z "${MASON_PACKAGE_header_only_hpp_PLATFORM+x}" ]
mason_succeeds "get PLATFORM_VERSION" [ -z "${MASON_PACKAGE_header_only_hpp_PLATFORM_VERSION+x}" ]
mason_succeeds "get INCLUDE_DIRS" [ "${MASON_PACKAGE_header_only_hpp_INCLUDE_DIRS}" = "`pwd`/mason_packages/headers/header-only.hpp/4.2/include" ]
mason_succeeds "get DEFINES" [ -z "${MASON_PACKAGE_header_only_hpp_DEFINES+x}" ]

# Install again and check that we don't output any status messages
mason_succeeds "install again is noop" [ "$(./mason.sh install header-only.hpp 4.2 --header-only 2>&1)" = "" ]
