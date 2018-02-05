## bcc

Learn more about this tool at https://github.com/iovisor/bcc

## Supports

 - Ubuntu >= precise
 - Centos >= 7
 - Amazon linux (tested on `2017.09.d`)
 - Running within docker

## Not Supported

Does not support running within a linux docker on a mac. The scripts will not compile since:

 - bpf looks for `/lib/modules/$(uname -r)` which will not match what is installable via apt/yum
 - `linux/bpf_common.h` will not be found during compile

Not yet tested:

 - alpine linux in docker from linux host (might or might not work?)


## Usage

First make sure you are running as root:

```
sudo su
```

Then setup debugfs:

```
mount -t debugfs nodev /sys/kernel/debug
```

If you forget this you will see this error when trying to run one of the bcc tools:

```
open(/sys/kernel/debug/tracing/kprobe_events): No such file or directory
```

Then:

 - install bcc via mason
 - enable the bcc python modules via `PYTHONPATH`
 - setup `LD_LIBRARY_PATH` so that the python module's `ctypes` import can find `libbcc.so`:
 - put the bbc tools on `PATH`

```
BCC_VERSION=e6c7568
mason install bcc ${BCC_VERSION}
BCC_PATH=$(mason prefix bcc ${BCC_VERSION})
export PYTHONPATH=${BCC_PATH}/lib/python2.7/dist-packages
export LD_LIBRARY_PATH=${BCC_PATH}/lib/
export PATH=${BCC_PATH}/share/bcc/tools:${PATH}
```


Then you should be able to run a command like

```
opensnoop -h
```

Which will display the help for `opensnoop`. Now try to use it to trace all failed reads for `node` binaries:


```
opensnoop -x -n node
```


Next confirm that in-kernel histograms are working by running:

```
biolatency
```

After a few seconds then hit `ctrl-c` to stop the program and it should display a histogram.

Read more about `biolatency` at https://github.com/iovisor/bcc/blob/master/docs/tutorial.md#14-biolatency

See all available tools you can run at https://github.com/iovisor/bcc#tools

And follow the bcc tutorial at https://github.com/iovisor/bcc/blob/master/docs/tutorial.md#1-general-performance
