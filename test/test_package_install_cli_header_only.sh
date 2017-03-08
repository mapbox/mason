./mason.sh install header-only.hpp 4.2 --header-only

# Check file existence
mason_succeeds "cached tarball" [ -f "mason_packages/.binaries/headers/header-only.hpp/4.2.tar.gz" ]
mason_succeeds "install folder" [ -d "mason_packages/headers/header-only.hpp/4.2" ]
mason_succeeds "unpacked ini file" [ -f "mason_packages/headers/header-only.hpp/4.2/mason.ini" ]
mason_succeeds "unpacked header file" [ -f "mason_packages/headers/header-only.hpp/4.2/include/header.h" ]

# Get arguments
mason_succeeds "get PREFIX" [ "`./mason.sh PREFIX --header-only header-only.hpp 4.2`" = "`pwd`/mason_packages/headers/header-only.hpp/4.2" ]
mason_succeeds "get prefix" [ "`./mason.sh prefix header-only.hpp --header-only 4.2`" = "`pwd`/mason_packages/headers/header-only.hpp/4.2" ]
mason_succeeds "get prEFix" [ "`./mason.sh prEFix header-only.hpp 4.2 --header-only`" = "`pwd`/mason_packages/headers/header-only.hpp/4.2" ]
mason_succeeds "get name" [ "`./mason.sh name --header-only header-only.hpp 4.2`" = "header-only.hpp" ]
mason_succeeds "get platform" [ "`./mason.sh platform --header-only header-only.hpp 4.2`" = "" ]
mason_succeeds "get platform_version" [ "`./mason.sh platform_version --header-only header-only.hpp 4.2`" = "" ]
mason_succeeds "get include_dirs" [ "`./mason.sh include_dirs --header-only header-only.hpp 4.2`" = "`pwd`/mason_packages/headers/header-only.hpp/4.2/include" ]
mason_succeeds "get definitions" [ "`./mason.sh definitions --header-only header-only.hpp 4.2`" = "" ]

# Install again and check that we don't output any status messages
mason_succeeds "install again is noop" [ "$(./mason.sh install header-only.hpp 4.2 --header-only 2>&1)" = "" ]
