# IAM VOMS-AA

VOMS Attribute Authority (VOMS-AA) is a plugin that provides backward-compatible VOMS support for a Virtual Organization managed with INDIGO IAM.
The VOMS Attribute Authority can access the IAM database and encode IAM groups and other attributes in a standard VOMS attribute certificate. This means that IAM can act both as an OAuth/OpenID Connect authorization server and as a VOMS server for a given organization. 

Docker Compose structure
-----------

The architecture of IAM with VOMS-AA embedded in [docker-compose.yml](https://baltig.infn.it/fornari/iam-voms-aa/-/blob/main/compose/docker-compose.yml) has been realized starting from the INDIGO IAM official [VOMS-AA Docker Compose file](https://github.com/indigo-iam/voms-aa/blob/master/compose/docker-compose.yml) and is meant to automatize services instantiation using INFN Cloud Docker Compose deployment functionality.  
Here is a scheme illustrating the architecture of the principal services.

<img src="pictures/iam-voms-aa.png?raw=true" width="500"/>

A description of the role played by each Docker Compose service is reported hereafter:

* `sidecar`: a CentOS 7 utility container providing a volume that contains configuration files and scripts useful to other containers.
* `trust`: a CentOS 7 utility container that contains fetch-crl and other utilities to provide up-to-date trust anchors to relying applications.
* `db`: a MySQL container starting a database where IAM will securely store its data.
* `iam-be`: a container running the IAM login service Java application.
* `nginx-iam`: an NGINX container that provides a reverse-proxy with SSL protecting the IAM login service.  
* `client`: an example OpenID Connect client application for IAM.
* `nginx-voms`: an OpenResty VOMS container providing TLS termination and client VOMS attribute certificate parsing and validation, deployed as a service that protects the VOMS-AA.
* `voms-aa`: a container running the VOMS Attribute Authority Java application.
* `voms-client`: a CentOS 7 container that provides VOMS client CLI with LSC and VOMSES files properly configured for a custom VO.

The correct start timing for those services that rely on other services is managed by the [`wait-for-it.sh`](https://github.com/vishnubob/wait-for-it) script by [vishnubob](https://github.com/vishnubob).

Deployment procedure on INFN Cloud
-----------

Connect to the [INFN-CLOUD dashboard](https://my.cloud.infn.it/). Authenticate with the credentials used for the [INFN-CLOUD IAM](https://iam.cloud.infn.it/login) account in order to access the dashboard.

<img src="pictures/infn_cloud_new_dashb.png?raw=true" width="600"/> <img src="pictures/infn_cloud_iam_login.png?raw=true" width="250"/>

After login into the dashboard, select the `Docker-compose` card in the service catalog and click on the Configure button.

![INFN-CLOUD Docker-compose](pictures/infn_cloud_docker_compose_card.png?raw=true "INFN-CLOUD Docker-compose")

A menu is made available, as in the figure below, and a configuration of the docker storage must be chosen.

![INFN-CLOUD Docker storage](pictures/infn_cloud_docker_storage.png?raw=true "INFN-CLOUD Docker storage")

All deployments have a mandatory field `Description` that needs to be defined before submitting the deployment. In `General` TAB, one or more TCP or UDP ports/port ranges can be set to be open towards the VM running the services. IAM requires port 80 (HTTP) and 443 (HTTPS) to be open, while VOMS-AA needs port 15000 to be reachable.

![INFN-CLOUD Description and Ports](pictures/infn_cloud_description_ports.png?raw=true "INFN-CLOUD Description and Ports")

A flavor must be selected to allocate resources needed in terms of CPUs and RAM for the new VM.

![INFN-CLOUD Flavor](pictures/infn_cloud_flavor.png?raw=true "INFN-CLOUD Flavor")

A decision between starting or not one or more docker containers on the VM must be taken. Default value is `yes`.

![INFN-CLOUD Docker Decision](pictures/infn_cloud_docker_decision.png?raw=true "INFN-CLOUD Docker Decision")

In `Services` TAB, environment variables to be made available to the docker containers at runtime can be specified in the form of `key:value`. Multiple variables can be specified using the `ADD` button.  
Environment variables that contain the *server certificate* and *private key* are **mandatory**. The private key must be base64 encoded before being inserted as `IAM_PRIV_KEY` value, and this can be easily done using the [encode-private-key.sh](https://baltig.infn.it/fornari/iam-voms-aa/-/blob/main/scripts/encode-private-key.sh) script.  
Here is a list of the principal variables that can/**must** be set:

* `IAM_PRIV_KEY` **must** be filled with the base64 encoded content of the IAM server private key file.
* `IAM_CERT_URL` **must** be filled with the URL provided by [Sectigo](https://www.sectigostore.com) to download the requested server certificate. 
* `IAM_FQDN` **must** be set to the IAM server name contained in the server certificate.
* `IAM_VERSION` can be set to the preferred IAM release to be installed (default is `v1.6.0`).
* `VO_NAME` can be set to a custom VO name (default is `test.vo`).
* `USER_PRIV_KEY` can be set with the base64 encoded content of a VOMS client private key file.
* `USER_CERT_URL` can be set with the URL from which the VOMS client X.509 certificate can be downloaded. 
* `MYSQL_DB` can be set to a custom value (default is `db`).
* `MYSQL_USERNAME` can be set to a custom value (default is `iam`).
* `MYSQL_PWD` can be set to a custom value (default is `pwd`).
* `MYSQL_ROOT_PWD` can be set to a custom value (default is `pwd`).

![INFN-CLOUD Environment Variables](pictures/infn_cloud_env_vars.png?raw=true "INFN-CLOUD Environment Variables")

An URL must be provided from which the docker compose file to deploy will be downloaded. The present project is using an [Apache server](http://131.154.97.87:8080/docker-compose) deployed on Cloud@CNAF to expose the docker compose file.

![INFN-CLOUD Compose URL](pictures/infn_cloud_compose_url.png?raw=true "INFN-CLOUD Compose URL")

A name of the project has to be stated. This name will be used to create a folder under `/opt` on the VM to store the docker compose file.

![INFN-CLOUD Project Name](pictures/infn_cloud_project_name.png?raw=true "INFN-CLOUD Project Name")

In `Advanced` TAB, `Manual` or `Automatic` Scheduling can be selected, depending on the will to deploy the services on specific or random resources.

![INFN-CLOUD Advanced Tab](pictures/infn_cloud_advanced_tab.png?raw=true "INFN-CLOUD Advanced Tab")

After configuring all the parameters, proceed hitting the `Submit` button and wait a few minutes for the deployment to be completed.

![INFN-CLOUD Deployment Complete](pictures/infn_cloud_deployment_complete.png?raw=true "INFN-CLOUD Deployment Complete")

When the deployment is completed, the public IP of the freshly instantiated VM can be found in `Details -> Output values`.

![INFN-CLOUD Output Values](pictures/infn_cloud_output_values.png?raw=true "INFN-CLOUD Output Values")

In order for the client to properly contact the IAM server, this public IP must be mapped on the server FQDN in the `/etc/hosts` file of the client.

Testing VOMS-AA
-----------

IAM server can be accessed at `IAM_BASE_URL` using admin default credentials (`admin:password`); for security reasons it is recommended to change the password as soon as possible.

<img src="pictures/indigo_iam_login.png?raw=true" width="125"/> <img src="pictures/indigo_iam_dashb.png?raw=true" width="750"/>

An IAM user has to be created for testing purposes. On the IAM dashboard, hit `Users` on the left panel and then click on `+ Add User`. Fill the form with the user information.

![INDIGO-IAM Create User](pictures/indigo_iam_create_user.png?raw=true "INDIGO-IAM Create User")

Now, add a root group with the name selected for the custom VO. On the left panel of the IAM dashboard hit `Groups` and then click on `+ Add Root Group`. Fill the form with the VO name.

![INDIGO-IAM Create Group](pictures/indigo_iam_create_group.png?raw=true "INDIGO-IAM Create Group")

Add the previously created user to the group. Go to `Users`, click on the user profile and then hit `+ Add to group`. Select the VO group.

![INDIGO-IAM Add User to Group](pictures/indigo_iam_add_user_group.png?raw=true "INDIGO-IAM Add User to Group")

Add a personal X.509 certificate to the user. Click on `+ Add certificate` and then fill the form with the VO name as label and the content of the X.509 certificate file.

![INDIGO-IAM Add Cert to User](pictures/indigo_iam_add_cert_user.png?raw=true "INDIGO-IAM Add Cert to User")

Connect via SSH to the IAM server and then enter the `voms-client` container. Verify that a VOMS proxy can be fetched from the VOMS-AA service.

```
fornari@pc-fornari:~$ ssh 131.154.96.58
Welcome to Ubuntu 20.04.4 LTS (GNU/Linux 5.4.0-121-generic x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/advantage

  System information as of Mon Jul  4 18:17:50 CEST 2022

  System load:  1.93              Users logged in:                  0
  Usage of /:   8.2% of 77.36GB   IPv4 address for br-4714e3d0e50f: 172.17.0.1
  Memory usage: 41%               IPv4 address for docker0:         172.0.17.1
  Swap usage:   0%                IPv4 address for ens3:            10.10.0.252
  Processes:    194

 * Super-optimized for small spaces - read how we shrank the memory
   footprint of MicroK8s to make it the smallest full K8s around.

   https://ubuntu.com/blog/microk8s-memory-optimisation

0 updates can be applied immediately.


Last login: Mon Jul  4 18:16:00 2022 from 172.16.11.75
fornari@vnode-0:~$ cd /opt/iam-voms-aa/
fornari@vnode-0:/opt/iam-voms-aa$ docker-compose exec voms-client bash
[root@voms-client /]# voms-proxy-init --voms test.vo
Enter GRID pass phrase for this identity:
Contacting iam-indigo.cr.cnaf.infn.it:15000 [/DC=org/DC=terena/DC=tcs/C=IT/ST=Roma/O=Istituto Nazionale di Fisica Nucleare/CN=iam-indigo.cr.cnaf.infn.it] "test.vo"...
Remote VOMS server contacted succesfully.


Created proxy in /tmp/x509up_u0.

Your proxy is valid until Tue Jul 05 06:22:43 CEST 2022
[root@voms-client /]# voms-proxy-info -all
subject   : /DC=org/DC=terena/DC=tcs/C=IT/O=Istituto Nazionale di Fisica Nucleare/CN=Federico Fornari fornari@infn.it/CN=1041735720
issuer    : /DC=org/DC=terena/DC=tcs/C=IT/O=Istituto Nazionale di Fisica Nucleare/CN=Federico Fornari fornari@infn.it
identity  : /DC=org/DC=terena/DC=tcs/C=IT/O=Istituto Nazionale di Fisica Nucleare/CN=Federico Fornari fornari@infn.it
type      : RFC3820 compliant impersonation proxy
strength  : 2048
path      : /tmp/x509up_u0
timeleft  : 11:59:53
key usage : Digital Signature, Key Encipherment
=== VO test.vo extension information ===
VO        : test.vo
subject   : /DC=org/DC=terena/DC=tcs/C=IT/O=Istituto Nazionale di Fisica Nucleare/CN=Federico Fornari fornari@infn.it
issuer    : /DC=org/DC=terena/DC=tcs/C=IT/ST=Roma/O=Istituto Nazionale di Fisica Nucleare/CN=iam-indigo.cr.cnaf.infn.it
attribute : /test.vo
timeleft  : 11:59:52
uri       : iam-indigo.cr.cnaf.infn.it:15000

[root@voms-client /]#
```

Alternatively, the [build-voms-client.sh](https://baltig.infn.it/fornari/iam-voms-aa/-/blob/main/scripts/build-voms-client.sh) script can be used to locally create a Docker image for a properly configured VOMS client. Some environment variables may/**must** be set prior to the execution of the script:

* `IAM_CERT_URL` **must** be set to the URL from which the IAM server certificate can be downloaded.
* `USER_CERT_URL` can be set to the URL from which the client X.509 certificate can be downloaded.
* `USER_PRIV_KEY` can be set to the client base64-encoded private key (encoding can be done using [encode-private-key.sh](https://baltig.infn.it/fornari/iam-voms-aa/-/blob/main/scripts/encode-private-key.sh) script).
* `VO_NAME` can be set to a custom VO name (default is `test.vo`).

After the Docker image has been built, a Docker container can be started with `docker run` command, using the `--add-host` option to map the IAM server's IP on its FQDN. For example:

```
fornari@pc-fornari:~/iam-voms-aa$ docker run -it --rm --add-host iam-indigo.cr.cnaf.infn.it:131.154.96.58 voms-client
[user@14bb4c8fd087 /]$ voms-proxy-init --voms test.vo
Enter GRID pass phrase for this identity:
Contacting iam-indigo.cr.cnaf.infn.it:15000 [/DC=org/DC=terena/DC=tcs/C=IT/ST=Roma/O=Istituto Nazionale di Fisica Nucleare/CN=iam-indigo.cr.cnaf.infn.it] "test.vo"...
Remote VOMS server contacted succesfully.


Created proxy in /tmp/x509up_u1000.

Your proxy is valid until Wed Jul 06 04:44:42 UTC 2022
[user@14bb4c8fd087 /]$ voms-proxy-info -all
subject   : /DC=org/DC=terena/DC=tcs/C=IT/O=Istituto Nazionale di Fisica Nucleare/CN=Federico Fornari fornari@infn.it/CN=656001799
issuer    : /DC=org/DC=terena/DC=tcs/C=IT/O=Istituto Nazionale di Fisica Nucleare/CN=Federico Fornari fornari@infn.it
identity  : /DC=org/DC=terena/DC=tcs/C=IT/O=Istituto Nazionale di Fisica Nucleare/CN=Federico Fornari fornari@infn.it
type      : RFC3820 compliant impersonation proxy
strength  : 2048
path      : /tmp/x509up_u1000
timeleft  : 11:59:54
key usage : Digital Signature, Key Encipherment
=== VO test.vo extension information ===
VO        : test.vo
subject   : /DC=org/DC=terena/DC=tcs/C=IT/O=Istituto Nazionale di Fisica Nucleare/CN=Federico Fornari fornari@infn.it
issuer    : /DC=org/DC=terena/DC=tcs/C=IT/ST=Roma/O=Istituto Nazionale di Fisica Nucleare/CN=iam-indigo.cr.cnaf.infn.it
attribute : /test.vo
timeleft  : 11:59:54
uri       : iam-indigo.cr.cnaf.infn.it:15000

[user@14bb4c8fd087 /]$ exit
exit
fornari@pc-fornari:~/iam-voms-aa$
```

If the VOMS proxy needs to be provided on a server away from your local PC, where [Singularity](https://sylabs.io/singularity/) is available but your user has no superuser privileges, the `voms-client` Docker image can be converted to a Singularity image. Just run the [docker2singularity.sh](https://baltig.infn.it/fornari/iam-voms-aa/-/blob/main/scripts/docker2singularity.sh) script to produce a `voms-client.sif` file:

```
fornari@pc-fornari:~/iam-voms-aa$ ./scripts/docker2singularity.sh voms-client

Image Format: squashfs
Docker Image: voms-client
Container Name: voms-client

Inspected Size: 440 MB

(1/10) Creating a build sandbox...
(2/10) Exporting filesystem...
(3/10) Creating labels...
(4/10) Adding run script...
(5/10) Setting ENV variables...
(6/10) Adding mount points...
(7/10) Fixing permissions...
(8/10) Stopping and removing the container...
(9/10) Building squashfs container...
INFO:    Starting build...
INFO:    Creating SIF file...
INFO:    Build complete: /tmp/voms-client.sif
(10/10) Moving the image to the output folder...
    152,555,520 100%  446.19MB/s    0:00:00 (xfr#1, to-chk=0/1)
Final Size: 146MB
fornari@pc-fornari:~/iam-voms-aa$ ls -lrth voms-client.sif 
-rwxr-xr-x 1 root root 146M Jul  5 15:43 voms-client.sif
fornari@pc-fornari:~/iam-voms-aa$
```

The Singularity image can be copied everywhere you want. Then, a container can be started with `singularity run` command. Pay attention to always map the IAM server's IP on its FQDN. For example:

```
fornari@pc-fornari:~/iam-voms-aa$ scp voms-client.sif fefornar@lxplus.cern.ch:
Warning: Permanently added the ECDSA host key for IP address '137.138.121.84' to the list of known hosts.
Password: 
voms-client.sif                                                            100%  145MB   6.7MB/s   00:21    
fornari@pc-fornari:~/iam-voms-aa$ ssh fefornar@lxplus.cern.ch
Warning: Permanently added the ECDSA host key for IP address '188.185.31.134' to the list of known hosts.
Password: 
* ********************************************************************
* Welcome to lxplus702.cern.ch, CentOS Linux release 7.9.2009 (Core)
* Archive of news is available in /etc/motd-archive
* Reminder: you have agreed to the CERN
*   computing rules, in particular OC5. CERN implements
*   the measures necessary to ensure compliance.
*   https://cern.ch/ComputingRules
* Puppet environment: production, Roger state: production
* Foreman hostgroup: lxplus/nodes/login
* Availability zone: cern-geneva-c
* LXPLUS Public Login Service - http://lxplusdoc.web.cern.ch/
* A CS8 based lxplus8.cern.ch is now available
* A C9 based lxplus9.cern.ch is now available
* Please read LXPLUS Privacy Notice in http://cern.ch/go/TpV7
* ********************************************************************
[fefornar@lxplus702 ~]$ cat > hosts <<EOF
> 127.0.0.1 localhost
> 131.154.96.58 iam-indigo.cr.cnaf.infn.it
> EOF
[fefornar@lxplus702 ~]$ singularity run --no-home --writable --bind $PWD/hosts:/etc/hosts voms-client.sif
INFO:    Converting SIF file to temporary sandbox...
Singularity> voms-proxy-init --voms test.vo
Enter GRID pass phrase for this identity:
Contacting iam-indigo.cr.cnaf.infn.it:15000 [/DC=org/DC=terena/DC=tcs/C=IT/ST=Roma/O=Istituto Nazionale di Fisica Nucleare/CN=iam-indigo.cr.cnaf.infn.it] "test.vo"...
Remote VOMS server contacted succesfully.


Created proxy in /tmp/x509up_u145411.

Your proxy is valid until Wed Jul 06 04:58:46 UTC 2022
Singularity> voms-proxy-info -all
subject   : /DC=org/DC=terena/DC=tcs/C=IT/O=Istituto Nazionale di Fisica Nucleare/CN=Federico Fornari fornari@infn.it/CN=1340947944
issuer    : /DC=org/DC=terena/DC=tcs/C=IT/O=Istituto Nazionale di Fisica Nucleare/CN=Federico Fornari fornari@infn.it
identity  : /DC=org/DC=terena/DC=tcs/C=IT/O=Istituto Nazionale di Fisica Nucleare/CN=Federico Fornari fornari@infn.it
type      : RFC3820 compliant impersonation proxy
strength  : 2048
path      : /tmp/x509up_u145411
timeleft  : 11:59:54
key usage : Digital Signature, Key Encipherment
=== VO test.vo extension information ===
VO        : test.vo
subject   : /DC=org/DC=terena/DC=tcs/C=IT/O=Istituto Nazionale di Fisica Nucleare/CN=Federico Fornari fornari@infn.it
issuer    : /DC=org/DC=terena/DC=tcs/C=IT/ST=Roma/O=Istituto Nazionale di Fisica Nucleare/CN=iam-indigo.cr.cnaf.infn.it
attribute : /test.vo
timeleft  : 11:59:54
uri       : iam-indigo.cr.cnaf.infn.it:15000

Singularity> exit
exit
INFO:    Cleaning up image...
[fefornar@lxplus702 ~]$
```
