#!/bin/sh

sudo rpm -Uvh http://yum.postgresql.org/9.4/redhat/rhel-7-x86_64/pgdg-centos94-9.4-1.noarch.rpm

sudo yum update

sudo yum install postgresql94-server postgresql94-contrib
