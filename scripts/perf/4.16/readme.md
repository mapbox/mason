This is the expected/enabled features of this perf build:

Taken from https://travis-ci.org/mapbox/mason/builds/336964403#L613

...                         dwarf: [ on  ]
...            dwarf_getlocations: [ on  ]
...                         glibc: [ on  ]
...                          gtk2: [ OFF ]
...                      libaudit: [ OFF ]
...                        libbfd: [ on  ]
...                        libelf: [ on  ]
...                       libnuma: [ OFF ]
...        numa_num_possible_cpus: [ OFF ]
...                       libperl: [ OFF ]
...                     libpython: [ on  ]
...                      libslang: [ on  ]
...                     libcrypto: [ on  ]
...                     libunwind: [ OFF ]
...            libdw-dwarf-unwind: [ on  ]
...                          zlib: [ on  ]
...                          lzma: [ on  ]
...                     get_cpuid: [ on  ]
...                           bpf: [ on  ]
...                     backtrace: [ on  ]
...                fortify-source: [ on  ]
...         sync-compare-and-swap: [ on  ]
...                  gtk2-infobar: [ OFF ]
...             libelf-getphdrnum: [ on  ]
...           libelf-gelf_getnote: [ on  ]
...          libelf-getshdrstrndx: [ on  ]
...                   libelf-mmap: [ on  ]
...             libpython-version: [ on  ]
...                 libunwind-x86: [ OFF ]
...              libunwind-x86_64: [ OFF ]
...                 libunwind-arm: [ OFF ]
...             libunwind-aarch64: [ OFF ]
...   pthread-attr-setaffinity-np: [ on  ]
...            stackprotector-all: [ on  ]
...                       timerfd: [ on  ]
...                  sched_getcpu: [ on  ]
...                           sdt: [ on  ]
...                         setns: [ on  ]
Makefile.config:613: Python support disabled by user
...                        prefix: /home/travis/build/mapbox/mason/mason_packages/linux-x86_64/perf/4.15
...                        bindir: /home/travis/build/mapbox/mason/mason_packages/linux-x86_64/perf/4.15/bin
...                        libdir: /home/travis/build/mapbox/mason/mason_packages/linux-x86_64/perf/4.15/lib64
...                    sysconfdir: /home/travis/build/mapbox/mason/mason_packages/linux-x86_64/perf/4.15/etc
...                 LIBUNWIND_DIR: 
...                     LIBDW_DIR: 
...                          JDIR: /usr/lib/jvm/java-1.7.0-openjdk-amd64
...     DWARF post unwind library: libdw