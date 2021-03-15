# Ansible for Developers

### Additional requirements before using this repository.
- Contact someone from the DevOps team in order to:
    - Obtain access to EC2 servers running on us-east-2.
    - Obtain access to AWS ECR for our Docker images.
    - Obtain a copy of the Ansible vault password file to store in the repository on your local computer. **NEVER commit this file to the repository.**
- Install AWS command line interface >= version 2 (AWS CLI v2). 
- Test whether you can login to AWS ECR via Docker by running the following command:
    - `aws ecr get-login-password | docker login -u AWS --password-stdin https://100225593120.dkr.ecr.us-east-1.amazonaws.com`
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
- Login to the AWS ECR repo via Docker by running the command `make registry-login-docker`.
    - This command may fail for Python 3 virtual environments.
    - In this case, please run the command manually: `aws ecr get-login-password | docker login -u AWS --password-stdin https://100225593120.dkr.ecr.us-east-1.amazonaws.com`.
        - The command `aws` may need to be written as `awsv2` for certain Python installations. If `aws` fails, try using `awsv2`.
- Run the command `make launch` from the root directory to launch your AWS instance.
- Check the Slack `#aws` channel for your server IP address and URL.
- Logs are viewable online: 
    - `http://{YOUR_NET_VALUE}-dev.alliancegenome.org:5601/app/logtrail`
    - Click the `All Systems` button at the bottom of the LogTrail screen to view output from different Docker containers on your server.
    - After launching new services, the browser window may need to be refreshed before the output appears in the `All Systems` dropdown.
  
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
|`run_loader_tests`| Runs the loader's integrated tests. This requires a populated Neo4J server.|
|`run_indexer`| Run the indexer.|
|`start_infinispan`| Start infinispan.|
|`run_cacher`| Run the cacher. Requires starting infinispan first.|
|`run_api`| Start the API.|
|`start_ui`| Start the UI.|
|`start_nginx`| Start Nginx.|
|`run_jbrowse`| TODO ~~Run a JBrowse instance~~.|

### Important Note regarding the Indexer and generating indexes.
- Once the indexer is run, it will generate a timestamped index using your ENV name, _e.g._ `site_index_chris_1615817944264
`.
- You'll need to launch Cerebro via the web interface on your server and assign an alias for this index in order to launch a functioning website.
    - Visit `http://{YOUR_NET_VALUE}-dev.alliancegenome.org:9000/`
    - Login with the node address `http://elasticsearch:9200`
    - Click `more` at the top navigation bar and choose `aliases`. 
    - Under `changes` on the right, type `site_index` in the alias box and then choose your newly created index from the `select index` dropdown.
    - Click the plus symbol to the far right.
    - Click the apply button to the far right.
- This process will need to be repeated _each time_ the indexer is run. We are currently working to automate this process and will update this README with any changes in the near future.  

### Terminate the AWS EC2 instance.
- When you are finished working with your instance, be sure to shut it down with the command `make terminate` run from the `agr_ansible_developers` directory. The `hosts` file _must include_ your server's IP address under the `[remote]` section, as described earlier.

## Example use cases

### Running the loader using a GitHub branch in the `build` environment.
- Be sure to follow all the preliminary steps above at the top of this readme.
- Ensure the following variables are set in your `main.yml` file:
    - Neo4J
        - `NEO_ENV_IMAGE_FROM_AWS_TAG: build`
        - `DOWNLOAD_NEO4J_DATA_IMAGE_FROM_AWS: false`
    - Loader
        - `DOWNLOAD_LOADER_IMAGE_FROM_AWS: True`
        - `GITHUB_LOADER_BRANCH: "AGR-1234"` (Set `AGR-1234` to your GitHub branch.)
- Run the following command to bring your server online:
    - `make launch`
- Logs can be viewed from the web address: `http://{YOUR_NET_VALUE}-dev.alliancegenome.org:5601/app/logtrail`
- Add the IP address of the server to the `[remote]` section of your `hosts` file.
- Start Neo4J as an empty database:
    - `make startdb`
- Run the loader:
    - `make run_loader`
- When finished, terminate your server:
    - `make terminate`

### Running the indexer using a GitHub branch in the `stage` environment with a prepopulated `stage` Neo4J.
- Be sure to follow all the preliminary steps above at the top of this readme.
- Ensure the following variables are set in your `main.yml` file:
    - Neo4J
        - `DOWNLOAD_NEO4J_DATA_IMAGE_FROM_AWS: true`
        - `NEO4J_DATA_IMAGE_FROM_AWS_TAG: stage`
    - Indexer, Cacher, and API settings
        - `DOWNLOAD_JAVA_SOFTWARE_IMAGE_FROM_AWS: false`
        - `GITHUB_JAVA_SOFTWARE_BRANCH: "AGR-1234"` (Set `AGR-1234` to your GitHub branch.)
    - Elasticsearch, Kibana, & Logstash settings
        - `ES_IMAGE_FROM_AWS_TAG: stage`
- Run the following command to bring your server online:
    - `make launch`
- Logs can be viewed from the web address: `http://{YOUR_NET_VALUE}-dev.alliancegenome.org:5601/app/logtrail`
- Add the IP address of the server to the `[remote]` section of your `hosts` file.
- Start Neo4J as a prepopulated database:
    - `make startdb`
- Run the indexer with your custom branch:
    - `make run_indexer`
- When finished, terminate your server:
    - `make terminate`
  
### Launch a website using a GitHub branch for the UI with prepopulated data from `build`.
- Be sure to follow all the preliminary steps above at the top of this readme.
- Ensure the following variables are set in your `main.yml` file:
    - Neo4J
        - `DOWNLOAD_NEO4J_DATA_IMAGE_FROM_AWS: true`
        - `NEO4J_DATA_IMAGE_FROM_AWS_TAG: build`
    - Indexer, Cacher, and API settings
        - `DOWNLOAD_JAVA_SOFTWARE_IMAGE_FROM_AWS: true`
        - `JAVA_SOFTWARE_IMAGE_FROM_AWS_TAG: build`
    - Elasticsearch, Kibana, & Logstash settings
        - `ES_IMAGE_FROM_AWS_TAG: build`
    - Infinispan settings
        - `DOWNLOAD_INFINISPAN_DATA_IMAGE_FROM_AWS: true`
        - `INFINISPAN_DATA_IMAGE_FROM_AWS_TAG: build`
    - UI settings
        - `DOWNLOAD_UI_IMAGE_FROM_AWS: false`
        - `GITHUB_UI_BRANCH: "AGR-1234"` (Set `AGR-1234` to your GitHub branch.)
    - Nginx settings
        - `NGINX_IMAGE_FROM_AWS_TAG: build`
- Run the following command to bring your server online:
    - `make launch`
- Logs can be viewed from the web address: `http://{YOUR_NET_VALUE}-dev.alliancegenome.org:5601/app/logtrail`
- Add the IP address of the server to the `[remote]` section of your `hosts` file.
- Start Neo4J as a prepopulated database:
    - `make startdb`
- Run the indexer:
    - `make run_indexer`
    - After the indexer is finished, be sure to update the `site_index` as described above in the section above, "Important Note regarding the Indexer and generating indexes."
- Start Infinispan with prepopulated data:
    - `make start_infinispan`
- Start the API:
    - `make start_api`
- Start the UI with your custom branch:
    - `make start_ui`
- Start Nginx:
    - `make start_nginx`
- Your site should now be online at the following address:
    - `http://{YOUR_NET_VALUE}-dev.alliancegenome.org`
- When finished, terminate your server:
    - `make terminate`  