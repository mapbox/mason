source mason.sh

mason_use test 1.0

# Check file existence
mason_succeeds "cached tarball" [ -f "mason_packages/.binaries/${TEST_SLUG}/test/1.0.tar.gz" ]
mason_succeeds "install folder" [ -d "mason_packages/${TEST_SLUG}/test/1.0" ]
mason_succeeds "unpacked ini file" [ -f "mason_packages/${TEST_SLUG}/test/1.0/mason.ini" ]
mason_succeeds "unpacked archive file" [ -f "mason_packages/${TEST_SLUG}/test/1.0/lib/libtest.a" ]

# Get arguments
mason_succeeds "var PREFIX" [ "${MASON_PACKAGE_test_PREFIX}" = "`pwd`/mason_packages/${TEST_SLUG}/test/1.0" ]
mason_succeeds "var NAME" [ "${MASON_PACKAGE_test_NAME}" = "test" ]
mason_succeeds "var VERSION" [ "${MASON_PACKAGE_test_VERSION}" = "1.0" ]
mason_succeeds "var PLATFORM" [ "${MASON_PACKAGE_test_PLATFORM}" = "${TEST_PLATFORM}" ]
mason_succeeds "var PLATFORM_VERSION" [ "${MASON_PACKAGE_test_PLATFORM_VERSION}" = "${TEST_PLATFORM_VERSION}" ]
mason_succeeds "var INCLUDE_DIRS" [ "${MASON_PACKAGE_test_INCLUDE_DIRS}" = "`pwd`/mason_packages/${TEST_SLUG}/test/1.0/include" ]
mason_succeeds "var LDFLAGS" [ "${MASON_PACKAGE_test_LDFLAGS}" = "-lpthread" ]
mason_succeeds "var STATIC_LIBS" [ "${MASON_PACKAGE_test_STATIC_LIBS}" = "`pwd`/mason_packages/${TEST_SLUG}/test/1.0/lib/libtest.a" ]
mason_succeeds "var DEFINES" [ -z "${MASON_PACKAGE_test_DEFINES+x}" ]

# Install again and check that we don't output any status messages
mason_succeeds "install again is noop" [ "$(mason_use test 1.0 2>&1)" = "" ]
