#!/bin/bash

# log into each GlusterFS node (over SSH) and list information about where a
# file is stored on the bricks.

# run with ./brick-for-file.sh [-v] /path/to/file/on/mountpoint

# Configure these:

# A list of the GlusterFS nodes.  It is recommended to have root SSH key
# authorization from the host where you run this.
NODES="gluster-01 gluster-02 gluster-03 gluster-04"

# What are the brick mount points on each node?  Must be consistent.
BRICKS="/export/brick1/vol1 /export/brick2/vol2"

# Command-line arguments
FILE=$1
VERBOSE=0

if [ "-v" = "$FILE" ] ; then
  FILE=$2
  VERBOSE=1
elif [ "-h" = "$FILE" -o "--help" = "$FILE" -o "x" = "x$FILE" ] ; then
  echo "Usage: $0 [-v] /path/to/file" >&2
  exit 2
fi

for node in $NODES ; do 
  for brick in $BRICKS ; do 
    if [ $VERBOSE -eq 1 ] ; then
      ssh $node "test -e $brick$FILE && echo $node \$(ls -ild $brick$FILE)"
    else
      ssh $node test -e $brick$FILE && echo ${node}:$brick
    fi
  done
done

