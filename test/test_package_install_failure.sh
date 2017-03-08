mason_fails "install an invalid version" ./mason.sh install test 1.1

# Check that folders don't exist
mason_succeeds "cached tarball" [ ! -f "mason_packages/.binaries/${TEST_SLUG}/test/1.0.tar.gz" ]
mason_succeeds "install folder" [ ! -d "mason_packages/${TEST_SLUG}/test/1.0" ]
mason_succeeds "unpacked ini file" [ ! -f "mason_packages/${TEST_SLUG}/test/1.0/mason.ini" ]
mason_succeeds "unpacked archive file" [ ! -f "mason_packages/${TEST_SLUG}/test/1.0/lib/libtest.a" ]
