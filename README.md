CloudManage
==============

What it is?
---------------------

CloudManage is a very minimal tool that helps you manage servers in IaaS clouds.
It has minimal UI that will guide you from adding your favorite cloud provider
account to a running provisioned server.

This tool is using Apache [Deltacloud API](http://deltacloud.org) for provider API interactions, so you
can manage all clouds this project supports ([18+ providers now](http://deltacloud.apache.org/drivers.html#drivers)).

How does it work?
--------------------

The basic workflow could be described like this:

* Add the IaaS cloud provider account (API key and API secret)
* Create an SSH authentication blueprint (SSH key/password/whatever)
* Find the base operating system you want to use (image)
* Assign the SSH authentication to the image
* Choose the sizing of resulting server (CPU, memory, region, firewall..,)
* Create shell script(s) you want to push to the server and run it
* Launch the server!

This tool has frontend written in Sinatra framework and backend in Sequel and
[Sidekiq](http://sidekiq.org) for managing background tasks.
With that, CloudManage is very fast and can process hundred of servers without
any problem.


Installation and usage
-------------

Pre-requires: Ruby 1.9+ and OpenSSH installed.


* `git clone https://github.com/mfojtik/cloudmanage`
* `cd cloudmanage && bundle`
* Edit the `lib/cloud_manage.db` and change the database location (line 17.)
* `rake db:create`

To run this application you need to first start the [sidekiq]():

`./bin/sidekiq`

Sidekiq is managing the background jobs and workers for gathering metrics,
connecting and executing commands on servers, etc.

Then you can start the main application using:

`./bin/cloudmanage`

The application should be ready and running.

Screenshots
-------------

![account](https://raw.github.com/mfojtik/cloudmanage/master/screens/account.png)

![images](https://raw.github.com/mfojtik/cloudmanage/master/screens/images.png)

![images2](https://raw.github.com/mfojtik/cloudmanage/master/screens/images2.png)

![recipe](https://raw.github.com/mfojtik/cloudmanage/master/screens/recipe.png)

![launch](https://raw.github.com/mfojtik/cloudmanage/master/screens/launch.png)

![servers](https://raw.github.com/mfojtik/cloudmanage/master/screens/servers.png)

![server](https://raw.github.com/mfojtik/cloudmanage/master/screens/server.png)

License
--------
Apache License
Version 2.0, January 2004
http://www.apache.org/licenses/
