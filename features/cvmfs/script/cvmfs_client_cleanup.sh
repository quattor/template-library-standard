#!/bin/bash

#
# CernVM-FS client cleanup
#

# Clean if quota exceeded
quota=${1:-0}

# Clean if less than "threshold" left in the file system
threshold=${2:-1024}

# Size to try to reduce CernVM-FS repositories to
target=${3:-256}

# Cache dir
cache=${4:-/var/cache/cvmfs2}

# Check quota
exceeded=0
if [ $quota -gt 0 ]; then
    used=`du -sm $cache | awk '{print $1}' 2>/dev/null`
    if [ $used -gt $quota ]; then
        exceeded=1
    fi
fi

# Get list of repositories from local configuration file
if [ -f /etc/cvmfs/default.local ]; then
    source /etc/cvmfs/default.local
fi

# Do the cleanup if possible and necessary
if [ -n "$CVMFS_REPOSITORIES" -a -d $cache ]; then
    free=`df -Pm $cache | grep '^/' | awk '{print $4}'`
    if [ "$exceeded" -eq 1 -o "$free" -lt "$threshold" ]; then
        for i in `/bin/echo -n $CVMFS_REPOSITORIES | xargs -d, -i echo {} | sort -r`; do
            cd /cvmfs/$i/
            cvmfs-talk -i $i cleanup $target >/dev/null
        done
    fi
fi
