#!/usr/bin/env python

import os
import glob
from subprocess import Popen, PIPE

for item in glob.glob('./scripts/*/*/script.sh'):
   parts = item.split('/')
   package = parts[2]
   version = parts[3]
   stdin, stderr = Popen('./mason cflags %s %s' % (package, version), shell=True, stdout=PIPE, stderr=PIPE).communicate()
   if stderr and 'unbound' in stderr:
      print package, version, stderr


