gluster-scripts
===============

Collection of scripts to address issues with GlusterFS deployments.

Home repo: https://github.com/justindossey/gluster-scripts

Scripts:

* gfid/trace-gluster-file.sh: print all the DHT linkfiles associated with a file, along with the file itself.
* gfid/brick-for-file.sh: find all the bricks where a file is located in a GlusterFS cluster.

* permissions/fix-rebalanced-permissions.sh: Walk a GlusterFS mountpoint (from a client) in parallel and change 000 and 1000 permissions on files to 644.
