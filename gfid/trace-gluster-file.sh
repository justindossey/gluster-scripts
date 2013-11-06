#!/bin/bash
# find all the files with name x, plus all the DHT linkfiles for that file, on a single node.  
# If argument is a directory, also walk the directory and print data for the files in the directory.
# requires that attr be installed to work.

shopt -q -s nullglob

# two bricks per node. This lists the mount points on the GlusterFS server.
BRICKS="/export/brick1/vol1 /export/brick2/vol1"

FILE="$1"

if [ "x$FILE" = "x" -o "$FILE" = "-h" -o "$FILE" = "--help" ] ; then
  echo "Usage: $0 path/to/file/on/mount" >&2
  echo "Note: no leading slash" >&2
  exit 2
fi

GETFATTR="/usr/bin/getfattr"

if [ ! -x "$GETFATTR" ] ; then
  echo "Error: getfattr not found at $GETFATTR  install attr then retry" >&2
  exit 1
fi

TRANSLATE_ATTR_TO_FN='2s/.*0x\(..\)\(..\)\(....\)\(....\)\(....\)\(....\)\(............\)/\1\/\2\/\1\2\3-\4-\5-\6-\7/p'

function print_link_traversal () {
  local fn="$1"
  echo "$fn"
  if [ -L "$fn" ] ; then
    local next_link_target=$(readlink "$fn")
    local fq_next_link_target="$(dirname $fn)/$next_link_target"
    print_link_traversal "$fq_next_link_target"
  fi
}

function print_glusterfs_data () {
  local brick="$1"
  local fn="$2"
  if [ -e "$brick/$fn" ] ; then
    echo "$brick/$fn"
    local gluster_fn=$("$GETFATTR" -m gfid -d -e hex "$brick/$fn" 2>/dev/null |sed -n "$TRANSLATE_ATTR_TO_FN")
    local fq_gluster_fn="$brick/.glusterfs/$gluster_fn"
    if [ -e "$fq_gluster_fn" ] ; then
      print_link_traversal "$fq_gluster_fn"
    fi
  fi
}

function recursive_get_gluster_files () {
  local brick="$1"
  local directory="$2"
  for gfilename in $brick/$directory/* ; do
    local fn=${gfilename#$brick/}
    print_glusterfs_data "$brick" "$fn"
    if [ -d "$gfilename" ] ; then
      recursive_get_gluster_files "$gfilename"
    fi
  done
}

for brick in $BRICKS ; do 
  filename="$brick/$FILE"
  print_glusterfs_data "$brick" "$FILE"
  if [ -d "$filename" ] ; then
    recursive_get_gluster_files "$brick" "$FILE"
  fi
done



