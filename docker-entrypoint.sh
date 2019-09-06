#!/bin/bash

set -e
umask u+rxw,g+rwx,o-rwx

#
# XVFB
#
Xvfb :99 -ac -screen 0 1280x1024x16 -nolisten tcp &
xvfb=$!
export DISPLAY=:99

#
# EXEC
#
exec "$@"
