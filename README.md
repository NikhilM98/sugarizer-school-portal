# Sugarizer School Portal

[**Sugarizer**](https://github.com/llaske/sugarizer) is the open-source learning platform based on Sugar that began in the famous One Laptop Per Child project.

[**Sugarizer Server**](https://github.com/llaske/sugarizer-server) allows the deployment of Sugarizer on a local server, for example on a school server, so expose Sugarizer locally as a Web Application. Sugarizer Server can also be used to provide collaboration features for Sugarizer Application on the network. Sugarizer Server could be deployed in a Docker container or on any computer with Node.js 6+ and MongoDB 2.6+.

**Sugarizer School Portal** is a new tool in the Sugarizer family which provides a way for schools interested by Sugarizer to host and manage themselves their Sugarizer deployment. It provides an on-demand (SaaS) Sugarizer Server deployment tool so that every school will be able to create a Sugarizer Server to host its own deployment without any technical skill in just a few clicks.

Under the hood, Sugarizer School Portal is a [Kubernetes](https://kubernetes.io/) cluster that is able to create/manage on-demand new Sugarizer Server instances.

The Sugarizer School Portal consists of multiple components:
- [Sugarizer School Portal Server](https://github.com/nikhilm98/sugarizer-school-portal-server)
- [Sugarizer Chart](https://github.com/nikhilm98/sugarizer-chart)
- [Sugarizer School Portal Chart](https://github.com/nikhilm98/sugarizer-school-portal-chart)

[**Sugarizer School Portal Server**](https://github.com/nikhilm98/sugarizer-school-portal-server) provides a web interface for the Sugarizer School Portal. It provides a role-based authentication for Clients, Moderators and Administrators, where the users can request for deployment by filling a simple form. The users can also monitor their deployment requests. The deployment administrators can monitor the users and approve/reject/deploy the requested deployments. It also allows the users to create admin accounts on their Sugarizer Server deployment directly from the interface

[**Sugarizer Chart**](https://github.com/nikhilm98/sugarizer-chart) is a collection of [Helm](https://helm.sh/) Charts for setting up [Sugarizer Server](https://github.com/llaske/sugarizer-server) deployment on a Kubernetes cluster. You can deploy multiple Sugarizer Server instances by editing the values of the YAML file and running simple `helm install` command. The Sugarizer Server instances are accessible from the browser by opening the `hostName` URL. Currently, it supports two providers:
- [Google Kubernetes Engine](https://cloud.google.com/kubernetes-engine) (GKE) - [README](https://github.com/NikhilM98/sugarizer-chart/tree/master/gke-environment)
- [Microk8s](https://microk8s.io) (For bare-metal Kubernetes cluster) - [README](https://github.com/NikhilM98/sugarizer-chart/tree/master/microk8s-environment)

The **Sugarizer School Portal Server** uses **Sugarizer Chart** to install a deployment in the Sugarizer School Portal Cluster.

[**Sugarizer School Portal Chart**](https://github.com/nikhilm98/sugarizer-school-portal-chart) is a [Helm](https://helm.sh/) Chart for setting up [Sugarizer School Portal Server](https://github.com/nikhilm98/sugarizer-school-portal-server) deployment on a Kubernetes cluster. You can deploy Sugarizer School Portal Server instance by editing the values of the YAML file and running simple `helm install` command. The Sugarizer School Portal Server instance can be accessed from the browser by opening the `hostName` URL.

The **Sugarizer School Portal Server** uses [**nodejs-helm**](https://www.npmjs.com/package/nodejs-helm) to interact with the Helm process. It is an [npm package](https://www.npmjs.com) which is a wrapper that integrates with the helm.sh process. The repository for the project is available on the [GitHub](https://github.com/) as [nikhilm98/nodejs-helm](https://github.com/NikhilM98/nodejs-helm).

## Setup
The [Sugarizer School Portal](https://github.com/NikhilM98/sugarizer-school-portal) also contains a set of [scripts](https://github.com/NikhilM98/sugarizer-school-portal/blob/master/scripts) which can be used to install dependencies, set-up the cluster environment and install the Sugarizer School Portal Chart on your GKE Cluster with a simple `sh setup.sh` command.

You can read more about the setup process in this [documentation](https://github.com/NikhilM98/sugarizer-school-portal/blob/master/scripts/README.md).

## Backup and Restore data using MGOB
[MGOB](https://github.com/stefanprodan/mgob/) is a MongoDB backup automation tool built with Go. It features like scheduled backups, local backups retention, upload to S3 Object Storage (Minio, AWS, Google Cloud, Azure) and upload to gcloud storage.

To setup MGOB to automate MongoDB backups on Google Kubernetes Engine, follow these step by step instructions:

Requirements:
- GKE cluster minimum version v1.8
- kubctl admin config

### Store Service Account key as a secret
First, you need to create a GCP service account key from the API & Services page. In case you already have one, then download the JSON file and rename it to `key.json`.

Store the JSON file as a secret:
```bash
kubectl create secret generic service-acc-secret --from-file=key.json
```

### MGOB Installation
Clone the MGOB repository:
```bash
git clone https://github.com/stefanprodan/mgob.git
cd mgob/chart
```
Edit the chart's `values.yaml` file.
- Set the appropriate `storageClass` for your provider.
- Update the `mgob-config` `configMap`. Add `sugarizer-database` backup plan.
Here is an example backup plan:
```bash
sugarizer-database.yml: |
  target:
    host: "mymongodb-mongodb-replicaset-0.mymongodb-mongodb-replicaset.default,mymongodb-mongodb-replicaset-1.mymongodb-mongodb-replicaset.default,mymongodb-mongodb-replicaset-2.mymongodb-mongodb-replicaset.default"
    port: 27017
    database: ""
  scheduler:
    cron: "0 0,6,12,18 */1 * *"
    retention: 14
    timeout: 60
```
- Add a reference to the secret. You can either insert your secret values as part of helm values or refer externally created secrets. In our case, we created a secret with a name `service-acc-secret`.
```bash
secret:
  - name: service-acc-secret
```
An example YAML configuration is available as [mgob-gke.yaml](examples/mgob-gke.yaml).

### Backup to GCP Storage Bucket (Optional)
For long term backup storage, you could use a GCP Bucket since is a cheaper option than keeping all backups on disk.    
You need to enable `storage.objects` acccess to the service account in order to allow objects creation in the bucket.    
From the GCP web UI, navigate to Storage and create a regional bucket named `ssp-backup` (Or any other name if it's taken). Set the bucket and secret name in the backup-plan in the `values.yaml` file.
```bash
gcloud:
  bucket: "ssp-backup"
  keyFilePath: /secret/service-acc-secret/key.json
```

### Restoring data from backup
In order to restore data to the Sugarizer School Portal database, you need to open a shell in MGOB pod. The backups are available in `/storage/sugarizer-database/` directory inside the pod (where `sugarizer-database` was the name of our backup plan).

- In case of a database error in which you need to completely restore all the databases, you can run:
```bash
mongorestore --gzip --archive=/storage/sugarizer-database/sugarizer-database-xxxxxxxxxx.gz --host mymongodb-mongodb-replicaset-0.mymongodb-mongodb-replicaset.default:27017 --drop
```
- In case a school's DB is messed up and you need to restore that, you can run:
```bash
mongorestore --gzip --archive=/storage/sugarizer-database/sugarizer-database-xxxxxxxxxx.gz --nsInclude="db_name.*" --host mymongodb-mongodb-replicaset-0.mymongodb-mongodb-replicaset.default:27017 --drop
```
Where db_name is the name of the database to restore.

## Contributing
Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

## License
This project is licensed under `Apache v2` License. See [LICENSE](LICENSE) for full license text.

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
