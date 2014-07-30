schof-alr-aio
=============

Create an all-in-one instance


If you don't have virtualenvwrapper and virtualenv installed:

```
sudo pip install virtualenv
sudo pip install virtualenvwrapper
```

Then configure your .bashrc file per http://virtualenvwrapper.readthedocs.org/en/latest/


```
git clone https://github.com/johnmarkschofield/schof-alr-aio.git
cd schof-alr-aio
mkvirtualenv schof-alr-aio -a `pwd`
pip install -r requirements.txt
```

Per http://www.rackspace.com/knowledge_center/article/installing-python-novaclient-on-linux-and-mac-os set up your authentication.

Your authentication can be in the cloudenv file or in ~/openrc or anywhere.

You'll need to edit the config variables in cloudenv.


```
./instance_provision.bash # Takes about 7-8 minutes.
source cloudenv
ssh $PUBLIC_IP
/root/install_openstack.bash # 22 minutes + 16min + 
```




```
source cloudenv
clean_slate.bash
```