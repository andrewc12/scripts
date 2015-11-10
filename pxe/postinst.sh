#!/bin/sh
touch /root/postinst.hello
mkdir -pm 700 /root/.ssh
echo 'ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAIEAhP5VvOuGObKch4q8H8CTIbZswuaaysvHxjZ0JBI2AIfbpPbGIPlKE5jKtNxoSITQdR6PNXu8UgoAdL1828QwcDCwsfjNg0G1Wv2+i/b6Kpd8M3DN9HyKk5C+2nXzfNw2ow5YfuN5GlbNEB7C6WYrQQsATqILB+45oDuZhjV43GE= postinstall key' > /root/.ssh/authorized_keys
echo 'ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAgEAiP0arxywVo1ZRtgb3cyKxwDtVBREsyYO2pIU5Qwb6/MCU1js0Q3U7vW0XfL4j1/BlJu83QHyvbCpt7XZW6THWcNUuNHBJLpZE/1nU5Z+kOcxFpX6M6ZB43/gLsZDU6ZV4qBmDW7FcBv4PUWQkIH1iQUCaJS6mhRpc9BdSDYaaisdurQkwzE5iEOGZJ4V6MoHSoskMilxe6rhkZpt5ZJ868YSNngT2i06ECkZizj7zDswWx9NezTBDrntFOqxjIUznvwcnAUVv9Q2Qvj1YMhjY1Mca6fKdqr8dea5VIyDItN4G4wShQ7J/4dupzrbeXhaKgsnnwNR32OWBTbgUW+8nTCbwOr5yi0BqQSCpVSKvGo4dee2/Ywt4eecU9VE1DE8+5hyCCPUtcWsBUhfU5o5eW4FyUr8rh6AkbzDR/YxrUzhO0JAtqe+mwQEIxwbkxkQhaz+w0lC/m97JMCjt2PeswLDq8YjkmT8NyEvyd573ukSBBP276fbOkMkvW/enpRTIyMbxQUHh5gI2yBcC8gSx1wXPihtJrl4KT65fRDKZovkAAr39Fsyeje/Zv2/Nh6YHnU2D6SpNKDa4wBk1aTy4ZTXuI7yfqsfnQS/TM+I/wj5fy+yRx6JNfVwb/9s/9nNYXpaKSwbQzD6trqpVSl/3edb/U9c7RxbELRqBvWNl1M= andrew it03' >> /root/.ssh/authorized_keys
chmod 0600 /root/.ssh/authorized_keys
chown -R root:root /root/.ssh
adduser --disabled-password --gecos "" ansible
su -c "mkdir -pm 700 ~/.ssh" ansible
su -c "echo 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDJE8h3gXqvtlNRIljS4IshJviaFPQjP/LlnQE0SQDAMxVvWwBWQqivGcVwygdyf82ivxTmzhN3pISR9rudGsiiwKTaj4dRwVBQcTu3YS2jaV4PQ/pbb1Hi8++zMz9UmFAXqd1L3DFnenW8OtlKf94Kg97QFikO10VtgUs3beQNUu9+WhXsNXGk5ngTUszA/rr4uSmq3jgNEHdwfgvW3bDRXM4CNE2yN4jYwuPhkRWrOh63QDU3jSFtrKyzGA/O979NJ9hpzR84w/rsOFz6aX9h+XIgHcqk2/ir0L5++/WerkBi0Q20B7ckRhqpKsrYaaNzIQPRkcrI98lDLNu7YDF3 ansible@ansible' > ~/.ssh/authorized_keys" ansible
su -c "chmod 0600 ~/.ssh/authorized_keys" ansible
su -c "chown -R ansible:ansible ~/.ssh" ansible
