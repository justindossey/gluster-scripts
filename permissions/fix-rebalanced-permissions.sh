#!/bin/bash

# walk a GlusterFS volume in parallel (from a client using the native FUSE
# mount) and set permissions on all files and directories with invalid
# permissions, as can happen during a rebalance.

# This script uses GNU Parallel, available at http://www.gnu.org/software/parallel

# permission to apply to files which bave 000 or 1000 permissions
FILE_CHMOD="0644"

# the mount point-- if your Gluster volume is mounted at /export/data, change
# this to /export/data.  Otherwise, the CWD is used.
MOUNT_POINT="."

# How many jobs to run simultaneously (to speed up the process).  Change to 0 for unlimited.
PARALLEL_JOBS="16"

# Today's date stamp
DATE=$(date +%Y%m%d)

# GNU Parallel stores a job log in this location.
JOB_LOG_FILE="/tmp/chmod-job-$DATE.log"

# With the -v option, chmod will announce every permission change.  Save this output to LOG_FILE.
LOG_FILE="/tmp/chmods-$DATE.log"

# the find command
parallel -P $PARALLEL_JOBS --joblog $JOB_LOG_FILE find "./{}" -type f -perm 000 -ls -exec chmod -v $FILE_CHMOD "\{\}" "\;" -o -type f -perm 1000 -ls -exec chmod -v $FILE_CHMOD "\{\}" "\;"  ::: * 2>&1 | tee $LOG_FILE
