#!/bin/sh

# Install keys
mkdir -pm 700 /root/.ssh
echo 'ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAIEAhP5VvOuGObKch4q8H8CTIbZswuaaysvHxjZ0JBI2AIfbpPbGIPlKE5jKtNxoSITQdR6PNXu8UgoAdL1828QwcDCwsfjNg0G1Wv2+i/b6Kpd8M3DN9HyKk5C+2nXzfNw2ow5YfuN5GlbNEB7C6WYrQQsATqILB+45oDuZhjV43GE= postinstall key' > /root/.ssh/authorized_keys
chmod 0600 /root/.ssh/authorized_keys
chown -R root:root /root/.ssh

mkdir -pm 700 /root/.ssh && echo 'ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAIEAhP5VvOuGObKch4q8H8CTIbZswuaaysvHxjZ0JBI2AIfbpPbGIPlKE5jKtNxoSITQdR6PNXu8UgoAdL1828QwcDCwsfjNg0G1Wv2+i/b6Kpd8M3DN9HyKk5C+2nXzfNw2ow5YfuN5GlbNEB7C6WYrQQsATqILB+45oDuZhjV43GE= postinstall key' > /root/.ssh/authorized_keys && chmod 0600 /root/.ssh/authorized_keys && chown -R root:root /root/.ssh
