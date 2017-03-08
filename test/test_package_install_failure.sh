# Test without parameter
if RESULT=$(./mason.sh install test 1.1 --header-only 2>&1); then
    [ $? != 0 ] # should not return exit code 0
else
    [ "${RESULT}" = $'[Mason] Downloading package http://localhost:8000/test/packages/headers/test/1.1.tar.gz...
[Mason] curl: (22) The requested URL returned error: 404 Not Found' ]
fi

# Check that folders don't exist
mason_succeeds "cached tarball" [ ! -f "mason_packages/.binaries/${TEST_SLUG}/test/1.0.tar.gz" ]
mason_succeeds "install folder" [ ! -d "mason_packages/${TEST_SLUG}/test/1.0" ]
mason_succeeds "unpacked ini file" [ ! -f "mason_packages/${TEST_SLUG}/test/1.0/mason.ini" ]
mason_succeeds "unpacked archive file" [ ! -f "mason_packages/${TEST_SLUG}/test/1.0/lib/libtest.a" ]
