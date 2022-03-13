# Sugarizer School Portal Setup

A complete Setup Script for Sugarizer School Portal dependencies, environment, and the helm chart.

## Provider Support
Sugarizer School Portal Chart supports three providers:
- [Amazon Elastic Kubernetes Service](https://aws.amazon.com/eks/) (Amazon EKS)
- [Azure Kubernetes Service](https://azure.microsoft.com/en-in/services/kubernetes-service/) (AKS)
- [Google Kubernetes Engine](https://cloud.google.com/kubernetes-engine) (GKE)

## Instructions

Navigate into scripts directory and run `sh setup.sh -p <provider> -s <true/false>` from your terminal to set-up the environment for Sugarizer School Portal on the cluster.

```bash
# Clone the repository
git clone git@github.com:NikhilM98/sugarizer-school-portal.git

# Navigate into scripts directory
cd sugarizer-school-portal/scripts

# Execute setup script
sh setup.sh -p <provider> -s <true/false>

# <providers> can be aws/azure/gke 
```

**Provider (-p) :** Cloud provider for the Kubernetes Cluster. Options: `aws`, `azure`, `gke`.

**SSL (-s) :** Whether to install HTTPS components. Options: `true`, `false`.

After setting up the environment, the setup will pause.
Navigate to the repository root, update the chart [ssp-values.yaml](charts/ssp-values.yaml) file.

Update the `hostName` and `deployment.host` values in the [ssp-values.yaml](charts/ssp-values.yaml) file. You don't need to update the `cluster` values if you have set SSL (-s) to `false` (`sh setup.sh -p <provider> -s false`).

If you want client email validation in the Sugarizer School Portal deployment, set `verification.enabled` to `true` and fill the SMTP server details in the following sub-fields.

You can look at this [documentation](https://github.com/nikhilm98/sugarizer-school-portal-chart/#edit-default-values) for more info about the supported values. 

Press `Enter` to proceed once you have edited the chart values.

The [Sugarizer School Portal Chart](https://github.com/NikhilM98/sugarizer-school-portal-chart) will be installed with the release name `ssp`.

Note: Point the Address (`A`) Record of your Cloud DNS zone to the Cluster IP of the NGINX Ingress Controller.

## Usage

The setup checks and installs these prerequisites if they're not already present:
- [GCloud](https://cloud.google.com/sdk) - (If provider is `gke`)
- [Azure CLI](https://docs.microsoft.com/bs-latn-ba/cli/azure) - (If provider is `azure`)
- [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-welcome.html) - (If provider is `aws`)
- [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
- [Git](https://git-scm.com/)
- [Curl](https://curl.haxx.se/) - (If required)
- [GnuPG](https://gnupg.org/) - (If required)
- [Helm 3](https://helm.sh/)

It then checks and installs the required Helm charts:
- [MongoDB Replicaset](https://github.com/bitnami/charts/tree/master/bitnami/mongodb) as `ssp-mongodb` in `default` namespace.
- [Kubernetes-Reflector](https://github.com/emberstack/kubernetes-reflector) as `reflector` in `default` namespace. - (If SSL is `true`)
- [NGINX Ingress Controller](https://github.com/nginxinc/kubernetes-ingress/) as `ingress-nginx` in `default` namespace.
- [Cert-Manager](https://cert-manager.io/docs/) as `cert-manager` in `cert-manager` namespace. - (If SSL is `true`)

It then checks and installs [Sugarizer School Portal Helm Chart](https://github.com/NikhilM98/sugarizer-school-portal-chart) if everything is fine.
