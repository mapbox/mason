# Test without parameter
if RESULT=$(./mason.sh 2>&1); then
    [ $? != 0 ] # should not return exit code 0
else
    [ "${RESULT}" = $'[Mason] Usage: ./mason.sh <property> [--header-only] <name> <version>
[Mason] <property> is one of \'include_dirs\', \'definitions\', \'options\', \'ldflags\', \'static_libs\', or any custom variables in the package\'s mason.ini.' ]
fi

# Test without package name
if RESULT=$(./mason.sh install 2>&1); then
    [ $? != 0 ] # should not return exit code 0
else
    [ "${RESULT}" = $'[Mason] No package name given' ]
fi

# Test without version name
if RESULT=$(./mason.sh install test 2>&1); then
    [ $? != 0 ] # should not return exit code 0
else
    [ "${RESULT}" = $'[Mason] Specifying a version is required' ]
fi

# Test with too many parameters
if RESULT=$(./mason.sh install test 1.0 foo 2>&1); then
    [ $? != 0 ] # should not return exit code 0
else
    [ "${RESULT}" = $'[Mason] mason_use() called with unrecognized arguments: \'foo\'' ]
fi

# Test with missing ini file
if RESULT=$(./mason.sh install missing-ini 2.3 --header-only 2>&1); then
    [ $? != 0 ] # should not return exit code 0
else
    [ "${RESULT}" = $'[Mason] Downloading package http://localhost:8000/test/packages/headers/missing-ini/2.3.tar.gz...
[Mason] Unpacking package to mason_packages/headers/missing-ini/2.3...
[Mason] Could not find mason.ini for package missing-ini 2.3' ]
fi
