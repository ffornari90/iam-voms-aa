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

In order for the client to properly contact the IAM server, this public IP must be mapped on the server FQDN in the `/etc/hosts` file of the VOMS client.

Testing VOMS-AA
-----------

IAM server can be accessed at `IAM_BASE_URL` using admin default credentials (`admin:password`); for security reasons it is recommended to change the password as soon as possible.

<img src="pictures/indigo_iam_login.png?raw=true" width="170"/> <img src="pictures/indigo_iam_dashb.png?raw=true" width="720"/>

An IAM user has to be created for testing purposes. On the IAM dashboard, hit `Users` on the left panel and then click on `+ Add User`. Fill the form with the user information.

![INDIGO-IAM Create User](pictures/indigo_iam_create_user.png?raw=true "INDIGO-IAM Create User")

Now, add a root group with the name selected for the custom VO. On the left panel of the IAM dashboard hit `Groups` and then click on `+ Add Root Group`. Fill the form with the VO name.

![INDIGO-IAM Create Group](pictures/indigo_iam_create_group.png?raw=true "INDIGO-IAM Create Group")

Add the previously created user to the group. Go to `Users`, click on the user profile and then hit `+ Add to group`. Select the VO group.

![INDIGO-IAM Add User to Group](pictures/indigo_iam_add_user_group.png?raw=true "INDIGO-IAM Add User to Group")

Add a personal X.509 certificate to the user. Click on `+ Add certificate` and then fill the form with the VO name as label and the content of the X.509 certificate file.

![INDIGO-IAM Add Cert to User](pictures/indigo_iam_add_cert_user.png?raw=true "INDIGO-IAM Add Cert to User")

Connect via SSH to the IAM server and then enter the `voms-client` container.
