# Ansible for Developers

This repository will allow you to run any of the major stages of the Alliance data pipeline on an AWS instance using Docker images from AWS ECR, code from GitHub branches, or a combination of both.

Upon launching an AWS instance, a publicly-accessible URL is also created for demonstration and testing purposes (_e.g._ running a test version of the Alliance website for curator review).

### Additional requirements before using this repository.
- Please use version <= 20 for Docker. We've had issues with Docker version 21. Hopefully this will be resolved in the near future.
- Contact someone from the DevOps team in order to:
    - Obtain access to EC2 servers running on us-east-1 (requires your IP address).
    - Obtain access to AWS ECR for our Docker images.
    - Obtain access to the AnsibleDevelopers AWS secret for the Ansible vault.

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
    - After launching new services, the browser window may need to be refreshed before the output appears in the `All Systems` dropdown.
    
### Launch additional software on your AWS EC2 instance.
- The following commands are available (use `make` before each command):

| Make Command | Description |
|---|---|
|`launch`| Launch the AWS EC2 instance.|
|`terminate`| Terminate the AWS EC2 instance.
|`startdb`| Start the Neo4J database. Required before most other steps.|
|`stopdb`| Stop the Neo4J database. **This also removes the container.**|
|`restartdb`| Restart the Neo4J database **This removes and creates a new container.**|
|`startcurationdb`| Start the curation database. This database **must** be started before running the indexer.|
|`stopcurationdb`| Stop the curation database.|
|`restartcurationdb`| Restart the curation database.|
|`run_loader`| Run the loader.|
|`run_loader_tests`| Runs the loader's integrated tests. This requires a populated Neo4J database.|
|`run_file_generator`| Runs the file generator. **Will attempt to upload files to FMS.**|
|`run_file_generator_no_upload`| Runs the file generator without uploading files to the FMS.|
|`run_indexer`| Run the indexer. Requires both Neo4J (`startdb`) and the curation database (`startcurationdb`).|
|`run_mod_variant_indexer`| Run the MOD variant indexer.|
|`run_human_variant_indexer`| Run the human variant indexer.|
|`start_infinispan`| Start infinispan.|
|`run_cacher`| Run the cacher. Requires starting infinispan first.|
|`start_api`| Start the API.|
|`start_ui`| Start the UI.|
|`start_nginx`| Start Nginx. Should always be run last after all other services have started.|
|`restartelk`| Restart the ELK stack (ElasticSearch / Cerebro / Logstash / Kibana).|
|`feature-stack`| Launch a complete feature testing stack (Curation API, Java API, Indexer, UI, Nginx) in one command.|
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
- When you are finished working with your instance, be sure to shut it down with the command `make terminate` run from the `agr_ansible_developers` directory.

## Example use cases

### Running the loader using a GitHub branch in the `stage` environment.
- Be sure to follow all the preliminary steps above at the top of this readme.
- Ensure the following variables are set in your `main.yml` file:
    - Neo4J
        - `NEO_ENV_IMAGE_FROM_AWS_TAG: stage`
        - `DOWNLOAD_NEO4J_DATA_IMAGE_FROM_AWS: false`
    - Loader
        - `DOWNLOAD_LOADER_IMAGE_FROM_AWS: True`
        - `GITHUB_LOADER_BRANCH: "AGR-1234"` (Set `AGR-1234` to your GitHub branch.)
- Run the following command to bring your server online:
    - `make launch`
- Logs can be viewed from the web address: `http://{YOUR_NET_VALUE}-dev.alliancegenome.org:5601/app/logtrail`
- Start Neo4J as an empty database:
    - `make startdb`
- Run the loader:
    - `make run_loader`
- If you've pushed changes to your GitHub branch and need to re-run the loader:
    - `make restartdb`
    - `make run_loader`
- When finished, terminate your server:
    - `make terminate`

### Running the indexer using a GitHub branch in the `stage` environment with a prepopulated `stage` Neo4J.
- Be sure to follow all the preliminary steps above at the top of this readme.
- Ensure the following variables are set in your `main.yml` file:
    - Neo4J
        - `DOWNLOAD_NEO4J_DATA_IMAGE_FROM_AWS: true`
        - `NEO4J_DATA_IMAGE_FROM_AWS_TAG: stage`
    - Curation Database
        - `CURATION_IMAGE_FROM_AWS_TAG: stage`
        - `CURATION_RELEASE_VERSION: v0.15.0`
    - Indexer, Cacher, and API settings
        - `DOWNLOAD_JAVA_SOFTWARE_IMAGE_FROM_AWS: false`
        - `GITHUB_JAVA_SOFTWARE_BRANCH: "AGR-1234"` (Set `AGR-1234` to your GitHub branch.)
    - Elasticsearch, Kibana, & Logstash settings
        - `ES_IMAGE_FROM_AWS_TAG: stage`
- Run the following command to bring your server online:
    - `make launch`
- Logs can be viewed from the web address: `http://{YOUR_NET_VALUE}-dev.alliancegenome.org:5601/app/logtrail`
- Start Neo4J as a prepopulated database:
    - `make startdb`
- Start the curation database as a prepopulated database:
    - `make startcurationdb`
- Run the indexer with your custom branch:
    - `make run_indexer`
- If you've pushed changes to your GitHub branch and need to re-run the indexer, simply run the same command again:
    - `make run_indexer`
- When finished, terminate your server:
    - `make terminate`
  
### Launch a website using a GitHub branch for the UI with prepopulated data from `stage`.
- Be sure to follow all the preliminary steps above at the top of this readme.
- Ensure the following variables are set in your `main.yml` file:
    - Neo4J
        - `DOWNLOAD_NEO4J_DATA_IMAGE_FROM_AWS: true`
        - `NEO4J_DATA_IMAGE_FROM_AWS_TAG: stage`
    - Curation Database
        - `CURATION_IMAGE_FROM_AWS_TAG: stage`
        - `CURATION_RELEASE_VERSION: v0.15.0`
    - Indexer, Cacher, and API settings
        - `DOWNLOAD_JAVA_SOFTWARE_IMAGE_FROM_AWS: true`
        - `JAVA_SOFTWARE_IMAGE_FROM_AWS_TAG: stage`
    - Elasticsearch, Kibana, & Logstash settings
        - `ES_IMAGE_FROM_AWS_TAG: stage`
    - Infinispan settings
        - `DOWNLOAD_INFINISPAN_DATA_IMAGE_FROM_AWS: true`
        - `INFINISPAN_DATA_IMAGE_FROM_AWS_TAG: stage`
    - UI settings
        - `DOWNLOAD_UI_IMAGE_FROM_AWS: false`
        - `GITHUB_UI_BRANCH: "AGR-1234"` (Set `AGR-1234` to your GitHub branch.)
    - Nginx settings
        - `NGINX_IMAGE_FROM_AWS_TAG: stage`
- Run the following command to bring your server online:
    - `make launch`
- Logs can be viewed from the web address: `http://{YOUR_NET_VALUE}-dev.alliancegenome.org:5601/app/logtrail`
- Start Neo4J as a prepopulated database:
    - `make startdb`
- Start the curation database as a prepopulated database:
    - `make startcurationdb`   
- Run the indexer:
    - `make run_indexer`
    - After the indexer is finished, be sure to update the `site_index` as described above in the section above, ["Important Note regarding the Indexer and generating indexes."](#important-note-regarding-the-indexer-and-generating-indexes)
- Start Infinispan with prepopulated data:
    - `make start_infinispan`
- Start the API:
    - `make start_api`
- Start the UI with your custom branch:
    - `make start_ui`
- If you've pushed changes to your GitHub branch and need to restart the UI, simply run the same command again:
    - `make start_ui`  
- Start Nginx:
    - `make start_nginx`
- Your site should now be online at the following address:
    - `http://{YOUR_NET_VALUE}-dev.alliancegenome.org`
- When finished, terminate your server:
    - `make terminate`

### Launch a complete feature testing stack with one command.

This option launches **all components** needed for a complete feature instance in a single command. This is useful when you need to test features that span multiple components (Curation API, Java API, Indexer, UI) without running each `make` command separately.

#### What this command does

Running `make feature-stack` will automatically:
1. Launch an AWS EC2 instance
2. Start the ELK stack (Elasticsearch, Logstash, Kibana for logging)
3. Start Neo4J with prepopulated data from `stage`
4. Start the Curation stack (PostgreSQL + OpenSearch + Curation API)
5. Start Infinispan (caching layer)
6. Build and run the Indexer (from your GitHub branch)
7. Build and run the Cacher (from your GitHub branch)
8. Start the Java API server (from your GitHub branch)
9. Build and start the UI (from your GitHub branch)
10. Start Nginx so you can access the site via URL

#### Prerequisites

Before running this command, make sure you have:
1. Completed all the preliminary steps at the top of this README (AWS access, ECR access, vault access).
2. Created your own folder in the `environments` directory with a `main.yml` file.
3. Updated the `ENV` variable in the `Makefile` to match your folder name.

#### Required configuration in your `main.yml` file

Open your `environments/{YOUR_FOLDER}/main.yml` file and set the following variables:

**Your server name (REQUIRED):**
```yaml
NET: "your-name"  # e.g. "christiano" - This becomes your URL: christiano-dev.alliancegenome.org
```

**Neo4J settings (use prepopulated data from stage):**
```yaml
DOWNLOAD_NEO4J_DATA_IMAGE_FROM_AWS: true
NEO4J_DATA_IMAGE_FROM_AWS_TAG: stage
```

**Curation Database settings:**
```yaml
CURATION_IMAGE_FROM_AWS_TAG: stage
CURATION_RELEASE_VERSION: v0.22.0  # Check ECR for latest version
```

**Indexer, Cacher, and API settings (build from your GitHub branch):**
```yaml
DOWNLOAD_JAVA_SOFTWARE_IMAGE_FROM_AWS: false
GITHUB_JAVA_SOFTWARE_BRANCH: "YOUR-BRANCH-NAME"  # e.g. "SCRUM-1234" or "stage"
```

**Elasticsearch settings:**
```yaml
ES_IMAGE_FROM_AWS_TAG: stage
```

**UI settings (build from your GitHub branch):**
```yaml
DOWNLOAD_UI_IMAGE_FROM_AWS: false
GITHUB_UI_BRANCH: "YOUR-BRANCH-NAME"  # e.g. "SCRUM-1234" or "stage"
```

**Nginx settings:**
```yaml
NGINX_IMAGE_FROM_AWS_TAG: build
```

#### Optional configuration

**Running specific indexers only (OPTIONAL):**

By default, all indexers will run. If you want to run only specific indexers to save time, you can set:
```yaml
INDEXER_SPECIFIC_FLAGS: "GeneIndexer DiseaseIndexer"  # Only runs these two indexers
```

**If you want ALL indexers to run (the default behavior), leave this as empty quotes:**
```yaml
INDEXER_SPECIFIC_FLAGS: ""  # Empty quotes = run ALL indexers (this is the default)
```

**Running specific cachers only (OPTIONAL):**

Similarly, you can run specific cachers:
```yaml
CACHER_SPECIFIC_FLAGS: "GenePhenotypeCacher DiseaseCacher"  # Only runs these cachers
```

**If you want ALL cachers to run (the default behavior), leave this as empty quotes:**
```yaml
CACHER_SPECIFIC_FLAGS: ""  # Empty quotes = run ALL cachers (this is the default)
```

#### Running the feature stack

Once your `main.yml` is configured:

1. **Make sure the Makefile ENV matches your folder:**
   ```
   # In Makefile, set this to your folder name:
   ENV=christiano
   ```

2. **Run the feature stack:**
   ```bash
   make feature-stack
   ```

3. **Wait for completion.** This will take some time as it builds and starts all components.

4. **Update the site_index alias.** After the indexer finishes, you need to set the Elasticsearch alias:
    - Visit `http://{YOUR_NET_VALUE}-dev.alliancegenome.org:9000/`
    - Login with the node address `http://elasticsearch:9200`
    - Click `more` at the top navigation bar and choose `aliases`
    - Under `changes` on the right, type `site_index` in the alias box
    - Select your newly created index from the `select index` dropdown (it will have a timestamp like `site_index_christiano_1615817944264`)
    - Click the plus symbol to the far right
    - Click the apply button

5. **Access your site:**
    - Website: `https://{YOUR_NET_VALUE}-dev.alliancegenome.org`
    - Logs: `http://{YOUR_NET_VALUE}-dev.alliancegenome.org:5601/app/logtrail`

6. **When finished, terminate your server:**
   ```bash
   make terminate
   ```

#### Troubleshooting

- **Logs not appearing?** After launching services, refresh your browser window. New containers may take a moment to appear in the LogTrail dropdown.
- **Site not loading?** Make sure you've set the `site_index` alias in Cerebro (step 4 above).
- **Build failing?** Check that your GitHub branch names are correct and that the branches exist.
