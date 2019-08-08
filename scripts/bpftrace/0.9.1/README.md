## bcctrace

Learn more about this tool at https://github.com/iovisor/bpftrace

## Supports

 - Ubuntu >= xenial
 - Running within docker

Does not support Docker for mac, since the kernel is too old. Requires > 4.17 while docker for mac has 4.9.

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
If you forget this step you will likely see an error like:

```
create_probe_event: open(/sys/kernel/debug/tracing/uprobe_events): No such file or directory
```

Then:

 - install bpftrace via mason
 - setup `LD_LIBRARY_PATH` so that the bpftrace can find some shared libraries:
 - put the bpftrace on `PATH`

```
./mason install bpftrace 0.9.1
export LD_LIBRARY_PATH=$(./mason prefix bpftrace 0.9.1)/lib/
export PATH=$(./mason prefix bpftrace 0.9.1)/bin:$PATH
```

Then you should be able to run:

```
bpftrace -e 'BEGIN { printf("hello world\n"); }'
```

If you hit `perf_event_open(/sys/kernel/debug/tracing/events/uprobes/p__proc_self_exe_2b7600_1_bcc_176/id): Input/output error`, your kernel may be too old https://github.com/iovisor/bcc/issues/1516

If you hit:

```
/bpftrace/include/asm_goto_workaround.h:14:10: fatal error: 'linux/types.h' file not found
```

Try doing: `apt-get install build-essential`

If you hit:

```
definitions.h:9:3: error: unknown type name 's64'
definitions.h:11:3: error: unknown type name 's64'
definitions.h:12:3: error: unknown type name 'umode_t'
```

You are likely missing kernel headers.

To take a profiling trace and feed into flamescope do:

```
bpftrace -e 'profile:hz:99 { @[kstack] = count(); }' -o trace

curl -o stackcollapse-bpftrace.pl https://raw.githubusercontent.com/brendangregg/FlameGraph/master/stackcollapse-bpftrace.pl
chmod +x stackcollapse-bpftrace.pl
./stackcollapse-bpftrace.pl < trace > trace.ready
