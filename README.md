schof-alr-aio
=============

Create an all-in-one instance.




## Pre-Requisites (Your Computer)


If you don't have virtualenvwrapper and virtualenv installed:

```
sudo pip install virtualenv
sudo pip install virtualenvwrapper
```

Then configure your .bashrc file per http://virtualenvwrapper.readthedocs.org/en/latest/



Once you have virtualenv and virtualenvwrapper working:

```
git clone https://github.com/johnmarkschofield/schof-alr-aio.git
cd schof-alr-aio
mkvirtualenv schof-alr-aio -a `pwd`
pip install -r requirements.txt
```



## Setting up Authentication

Per http://www.rackspace.com/knowledge_center/article/installing-python-novaclient-on-linux-and-mac-os you'll need to set up your authentication.

Your authentication can be in the cloudenv file or in ~/openrc or anywhere.

You'll need to edit the config variables in cloudenv.


## Installing

```
time ./make_it_all.bash # Takes about 7-8 minutes.
source cloudenv
ssh $PUBLIC_IP
time /bin/bash /root/install_openstack.bash # Takes about 64 minutes
```


## Deleting

```
source cloudenv
nuke_it_from_orbit.bash
```