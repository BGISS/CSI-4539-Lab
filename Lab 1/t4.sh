#!/bin/bash
# E6a: the id command runs with catall's privilege.
# ruid=1000 but euid=0 (root)
./catall "x; id"
