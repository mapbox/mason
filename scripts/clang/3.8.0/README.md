### Clang++ v3.8.0

Usage on Travis:

```yml

matrix:
  include:
    - os: linux
      sudo: false
      env: CXX=clang++
      addons:
        apt:
          sources: [ 'ubuntu-toolchain-r-test' ]
          packages: [ 'libstdc++6','libstdc++-5-dev', 'g++-5' ]

install:
  - ./.mason/mason install clang 3.8.0
  - export PATH=$(./.mason/mason prefix clang 3.8.0)/bin:${PATH}
  - which clang++
```

### Notes:

#### Runtime dependencies:

 - 'libstdc++6'

#### Dependencies for building apps with clang++:

 - 'libstdc++-5-dev'
 - 'g++-5'

This clang++ package depends on and defaults to compiling C++ programs against libstdc++. The library soname is `6` but the actual library version used, at the time of this writing, is `v6.1.1` (this comes from https://launchpad.net/~ubuntu-toolchain-r/+archive/ubuntu/test/+packages). The `6` is a coincidence: even libstdc++ `v4.6.3` (the default on Ubuntu precise) is named `libstdc++6`

If you hit a runtime error like `/usr/lib/x86_64-linux-gnu/libstdc++.so.6: version GLIBCXX_3.4.20' not found` it means you forgot to upgrade libstdc++6 to at least `v6.1.1`. This can be done on travis like:

```
     addons:
        apt:
          sources: [ 'ubuntu-toolchain-r-test' ]
          packages: [ 'libstdc++6','libstdc++-5-dev', 'g++-5' ]
```

And via apt-get like:

```
add-apt-repository -y ppa:ubuntu-toolchain-r/test
apt-get update -y
apt-get install -y libstdc++6
```

