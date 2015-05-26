#!/bin/bash
for i in $(lxc-ls)
do
echo "stopping $i" && lxc-stop -n $i &
done
