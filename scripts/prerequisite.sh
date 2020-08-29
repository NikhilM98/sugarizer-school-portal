#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

# Load colors
RED='\033[0;31m';
GREEN='\033[0;32m';
YELLOW='\033[0;33m';
BLUE='\033[0;34m';
NC='\033[0m';

# Print Intro Message
printf "${YELLOW}\nChecking for dependencies...\n${NC}";

while getopts p: flag
do
    case "${flag}" in
        p) provider=${OPTARG};;
    esac
done

gcloud_instructions() {
    printf ${YELLOW};
    printf "\nPlease run:\n    $ gcloud auth login\nto obtain new credentials.\n\nIf you have already logged in with a different account:\n    $ gcloud config set account ACCOUNT\nto select an already authenticated account to use.\n";
    printf "\nAfter that, to connect with your cluster, please run:\n    $ gcloud container clusters get-credentials <custer_name> --zone <zone_name> --project <project_name>\n\n";
    printf ${NC};
}

azure_instructions() {
    printf ${YELLOW};
    printf "\nPlease run:\n    $ az login\nto sign in to Azure-CLI.\n";
    printf "\nAfter that, to connect with your cluster, please run:\n    $ az aks get-credentials --resource-group <resource_group> --name <custer_name>\n\n";
    printf ${NC};
}

aws_instructions() {
    printf ${YELLOW};
    printf "\nPlease run:\n    $ aws configure\nto configure the AWS CLI.\n";
    printf "\nAfter that, to connect with your cluster, please run:\n    $ aws eks --region <region> update-kubeconfig --name <cluster_name>\n\n";
    printf ${NC};
}

if [ -z ${provider+x} ]; then # provider is not set
    printf "${RED}\nSetup Aborted | Provider (-p) is not set.\n${NC}";
    exit 1;
elif [ "$provider" = "gke" ]; then # provider is set to gke
    command -v gcloud >/dev/null 2>&1 || {
        printf >&2 "${BLUE}Installing GCloud...\n${NC}";
        apt update && apt install -y gnupg2;
        command -v curl >/dev/null 2>&1 || {
            printf >&2 "${BLUE}Installing Curl...\n${NC}";
            apt -y install curl;
        }
        printf "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] http://packages.cloud.google.com/apt cloud-sdk main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list && curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key --keyring /usr/share/keyrings/cloud.google.gpg  add - && apt update -y && apt install google-cloud-sdk -y;
        printf "${RED}\nSetup Aborted | Login to GCloud account to continue.\n${NC}";
        gcloud_instructions;
        exit 1;
    }
elif [ "$provider" = "azure" ]; then # provider is set to azure
    command -v az >/dev/null 2>&1 || {
        printf >&2 "${BLUE}Installing Azure-CLI...\n${NC}";
        command -v curl >/dev/null 2>&1 || {
            printf >&2 "${BLUE}Installing Curl...\n${NC}";
            apt update && apt -y install curl;
        }
        curl -sL https://aka.ms/InstallAzureCLIDeb | bash;
        az aks install-cli;
        printf "${RED}\nSetup Aborted | Login to Azure CLI to continue.\n${NC}";
        azure_instructions;
        exit 1;
    }
elif [ "$provider" = "aws" ]; then # provider is set to aws
    command -v kubectl >/dev/null 2>&1 || {
        printf >&2 "${BLUE}Installing Kubectl...\n${NC}";
        apt update && apt install -y apt-transport-https gnupg2;
        command -v curl >/dev/null 2>&1 || {
            printf >&2 "${BLUE}Installing Curl...\n${NC}";
            apt update && apt -y install curl;
        }

        curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -;
        echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | tee -a /etc/apt/sources.list.d/kubernetes.list;
        apt update & apt-get install -y kubectl;
    }
    command -v aws >/dev/null 2>&1 || {
        printf >&2 "${BLUE}Installing AWS CLI...\n${NC}";
        command -v curl >/dev/null 2>&1 || {
            printf >&2 "${BLUE}Installing Curl...\n${NC}";
            apt update && apt -y install curl;
        }
        command -v unzip >/dev/null 2>&1 || {
            printf >&2 "${BLUE}Installing Unzip...\n${NC}";
            apt update && apt -y install unzip;
        }

        architecture=""
        case $(uname -m) in
            i386)   architecture="386";;
            i686)   architecture="386";;
            x86_64) architecture="amd64";;
            arm)    architecture="arm";;
        esac

        if [ "$architecture" = "arm" ]; then
            curl "https://awscli.amazonaws.com/awscli-exe-linux-aarch64.zip" -o "awscliv2.zip"
            unzip awscliv2.zip
            ./aws/install
        else
            curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
            unzip awscliv2.zip
            ./aws/install
        fi
        printf "${RED}\nSetup Aborted | Configure AWS CLI to continue.\n${NC}";
        aws_instructions;
        exit 1;
    }
else # provider has unaccepted input
    printf "${RED}\nSetup Aborted | Provider (-p) has unaccepted input ${YELLOW}'$provider'${RED}.\n${NC}";
    exit 1;
fi

command -v kubectl >/dev/null 2>&1 || {
    printf >&2 "${BLUE}Installing kubectl...\n${NC}";
    apt update && apt install kubectl;
}

command -v helm >/dev/null 2>&1 || {
    printf >&2 "${BLUE}Installing Helm 3...\n${NC}";
    command -v curl >/dev/null 2>&1 || {
        printf >&2 "${BLUE}Installing Curl...\n${NC}";
        apt update && apt -y install curl;
    }
    curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash;
}

command -v git >/dev/null 2>&1 || {
    printf >&2 "${BLUE}Installing Git...\n${NC}";
    apt update && apt -y install git;
}

# Check if the cluster is accessible
kubectl get pods >/dev/null 2>&1 || {
    printf >&2 "${RED}\nError: You're not connected with the cluster.\n${NC}";
    if [ "$provider" = "gke" ]; then
        gcloud_instructions;    
    elif [ "$provider" = "azure" ]; then
        azure_instructions;
    elif [ "$provider" = "aws" ]; then
        aws_instructions;
    fi
    exit 1;
}

# Print Exit Message
printf "${GREEN}Finished checking for dependencies\n\n${NC}";
