# Ansible for Developers

### Before cloning this repository.
- Contact someone from the DevOps team in order to:
    - Obtain access to EC2 servers running on us-east-2.
    - Obtain a copy of the Ansible vault password file to store in the repository on your local computer. **NEVER commit this file to the repository.**
    
### Clone the repository.
- Clone `agr_ansible_developers` to your local machine.

### Copy the template configuration files.
- Create your own directory in the `environments` folder. 
    - This directory can be committed to GitHub for future use.
- Copy the file `main.yml` from the `environments/template` directory to your newly created directory.

### Edit the configuration files before running.
#### main.yml
- In your newly created directory, edit the `main.yml` file.
- The `NET` value is used for the DNS name of your server. Please change it from `main` to another value, _e.g._ `olin`.
    - This value will be appended with `-dev`. 
    - The address will be structured as _e.g._ `olin-dev.alliancegenome.org`.
    - Once launched, this name will appear in the `#aws` channel of Slack along with your new server's IP address.
    
- The `ALLIANCE_RELEASE` value is used for the data snapshot from the FMS. Please change it to the appropriate release depending on your desired source data.

- For the remaining values, most of the configuration options allow the pipeline to be run using either **code from GitHub** or **images from AWS ECR**.
    - Please choose the appropriate configuration values based on the code you are testing.
    - If assistance is required, please post a message in the `#devops` channel on Slack and we'll be happy to help.
#### Makefile
- Before running Ansible, edit the Makefile variable `ENV` at the top of the file to match the name of the folder you've created in `environments`.

### Launch the AWS EC2 instance.
- Run the command `make launch` from the root directory to launch your AWS instance.
- Check the Slack `#aws` channel for your server IP address and URL.
- Logs are viewable online: 
    - `http://{YOUR_NET_VALUE}-dev.alliancegenome.org:5601/app/logtrail`
    - Click the `All Systems` button at the bottom of the LogTrail screen to view output from different Docker containers on your server.

### Edit the hosts file after running.
#### hosts
- After the instance is online, obtain the IP address from either the `#aws` Slack channel or the Ansible console on your local machine. The IP will be printed in the console after the server is launched.
- Open the `hosts` file in the `agr_ansible_developers` directory and change the IP address under `[remote]` to the newly obtained IP address.

### Launch additional software on your AWS EC2 instance.
- After editing the `hosts` file, other software can be launched on your AWS EC2 instance.
- The following commands are available (use `make` before each command):

| Make Command | Description |
|---|---|
|`launch`| Launch the AWS EC2 instance.|
|`terminate`| Terminate the AWS EC2 instance. Requires an updated `hosts` file with the current instance's IP address.|
|`startdb`| Start the Neo4J database. Required before most other steps.|
|`stopdb`| Stop the Neo4J database. **This also removes the container.**|
|`restartdb` | Restart the Neo4J database **This removes and creates a new container.**|
|`run_loader`| Run the loader.|
|`run_indexer`| Run the indexer.|
|`run_cacher`| Run the cacher.|
|`run_api`| Start the API.|
|`run_ui`| Start the UI.|
|`run_nginx`| Start Nginx.|
|`run_jbrowse`| TODO ~~Run a JBrowse instance~~.|

### Terminate the AWS EC2 instance.
- When you are finished working with your instance, be sure to shut it down with the command `make terminate` run from the `agr_ansible_developers` directory.