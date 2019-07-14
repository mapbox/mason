## bcctrace

Learn more about this tool at https://github.com/iovisor/bpftrace

## Supports

 - Ubuntu >= xenial
 - Running within docker

Xenial is needed because with trusty or before the code will not compile:

```
../src/list.h:19:35: error: use of undeclared identifier 'PERF_COUNT_SW_BPF_OUTPUT'; did you mean 'PERF_COUNT_SW_CPU_CLOCK'?
  { "bpf-output",       "",       PERF_COUNT_SW_BPF_OUTPUT,          1 },
                                  ^~~~~~~~~~~~~~~~~~~~~~~~
                                  PERF_COUNT_SW_CPU_CLOCK
/usr/include/linux/perf_event.h:103:2: note: 'PERF_COUNT_SW_CPU_CLOCK' declared here
        PERF_COUNT_SW_CPU_CLOCK                 = 0,
        ^
```

## Usage

First make sure you are running as root:

```
sudo su
```

Then setup debugfs:

```
mount -t debugfs debugfs /sys/kernel/debug/
```

Then:

 - install bpftrace via mason
 - setup `LD_LIBRARY_PATH` so that the bpftrace can find some shared libraries:
 - put the bpftrace on `PATH`

```
mason install bpftrace 0.9.1
export LD_LIBRARY_PATH=$(mason prefix bpftrace 0.9.1)/lib/
export PATH=$(mason prefix bpftrace 0.9.1)/bin:$PATH
```

Then you should be able to run:

```
bpftrace -e 'BEGIN { printf("hello world\n"); }'
```