./mason.sh install test 1.0

# Check file existence
mason_succeeds "cached tarball" [ -f "mason_packages/.binaries/${TEST_SLUG}/test/1.0.tar.gz" ]
mason_succeeds "install folder" [ -d "mason_packages/${TEST_SLUG}/test/1.0" ]
mason_succeeds "unpacked ini file" [ -f "mason_packages/${TEST_SLUG}/test/1.0/mason.ini" ]
mason_succeeds "unpacked archive file" [ -f "mason_packages/${TEST_SLUG}/test/1.0/lib/libtest.a" ]

# Get arguments
mason_succeeds "get PREFIX" [ "`./mason.sh PREFIX test 1.0`" = "`pwd`/mason_packages/${TEST_SLUG}/test/1.0" ]
mason_succeeds "get prefix" [ "`./mason.sh prefix test 1.0`" = "`pwd`/mason_packages/${TEST_SLUG}/test/1.0" ]
mason_succeeds "get prEFix" [ "`./mason.sh prEFix test 1.0`" = "`pwd`/mason_packages/${TEST_SLUG}/test/1.0" ]
mason_succeeds "get name" [ "`./mason.sh name test 1.0`" = "test" ]
mason_succeeds "get platform" [ "`./mason.sh platform test 1.0`" = "${TEST_PLATFORM}" ]
mason_succeeds "get platform_version" [ "`./mason.sh platform_version test 1.0`" = "${TEST_PLATFORM_VERSION}" ]
mason_succeeds "get include_dirs" [ "`./mason.sh include_dirs test 1.0`" = "`pwd`/mason_packages/${TEST_SLUG}/test/1.0/include" ]
mason_succeeds "get ldflags" [ "`./mason.sh ldflags test 1.0`" = "-lpthread" ]
mason_succeeds "get static_libs" [ "`./mason.sh static_libs test 1.0`" = "`pwd`/mason_packages/${TEST_SLUG}/test/1.0/lib/libtest.a" ]
mason_succeeds "get defines" [ "`./mason.sh defines test 1.0`" = "" ]

# Install again and check that we don't output any status messages
mason_succeeds "install again is noop" [ "$(./mason.sh install test 1.0 2>&1)" = "" ]
