File System Performance with O\_SYNC and O\_DIRECT
================================================

Overview
--------

This demonstration expands on the one done in _FILESYTEM PERFORMANCE_ by adding:
1. The O\_DIRECT flag
1. Increased granularity of times measured
1. Randomised tests (instead of doing tests sequentially through each combination of factors)
1. Use of [Ansible](https://www.ansible.com/) to set up and run tests
1. Use of multiple file system types

Warnings
--------

These scripts should __ONLY__ be run on __TEST__ machines as the scripts:
1. Required __ROOT__ access
1. Unmount __ALL__ loop-back devices
1. Installs additional software

Configuration
-------------

The target system, __DURAL.YAOCM.ID.AU__, is a VirtualBox 6.1 VM running Oracle Enterprise Linux 8.1 (OEL8.1).
 
Execution
---------

To run this demonstration, use the following command on a suitable Ansible server:
```bash
ansible-playbook -K sites.yml
```

You will be then prompted for your password for the remote servers.

Tests Done
----------

Currently, only four (4) file system types are tested:
1. EXT2
1. EXT3
1. EXT4
1. XFS
