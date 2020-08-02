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
printf "\n${GREEN}Sugarizer School Portal Setup${NC}\n";

while getopts s:p: flag
do
    case "${flag}" in
        s) ssl=${OPTARG};;
        p) provider=${OPTARG};;
    esac
done

if [ -z ${ssl+x} ]; then # SSL is not set
    printf "${YELLOW}\nSSL (-s) is not set | Taking SSL as ${GREEN}true${YELLOW}.\n${NC}";
    ssl='true';
elif [ "$ssl" = true ]; then # SSL is true
    printf "${YELLOW}\nSSL (-s) is set to ${GREEN}$ssl${YELLOW}.\n${NC}";
elif [ "$ssl" = false ]; then # SSL is false
    printf "${YELLOW}\nSSL (-s) is set to ${RED}$ssl${YELLOW}.\n${NC}";
else # SSL has unaccepted input
    printf "${RED}\nSetup Aborted | SSL (-s) has unaccepted input ${YELLOW}'$ssl'${RED}.\n${NC}";
    exit 1;
fi

if [ -z ${provider+x} ]; then # provider is not set
    printf "${RED}\nSetup Aborted | Provider (-p) is not set.\n${NC}";
    exit 1;
elif [ "$provider" = "gke" ]; then # provider is set to gke
    printf "${YELLOW}\nProvider (-p) is set to ${BLUE}$provider${YELLOW}.\n${NC}";
elif [ "$provider" = "azure" ]; then # provider is set to azure
    printf "${YELLOW}\nProvider (-p) is set to ${BLUE}$provider${YELLOW}.\n${NC}";
else # provider has unaccepted input
    printf "${RED}\nSetup Aborted | Provider (-p) has unaccepted input ${YELLOW}'$provider'${RED}.\n${NC}";
    exit 1;
fi

# Check for dependencies
sh prerequisite.sh -p $provider;

# Check for MongoDB-Replicaset
sh charts/mongodb.sh;

# Check for Kubernetes-Reflector
if [ "$ssl" = true ]; then # SSL is not set
    sh charts/reflector.sh;
fi

# Check for NGINX Ingress Controller
sh charts/nginxinc.sh -s $ssl;

# Check for Cert-Manager
if [ "$ssl" = true ]; then # SSL is not set
    sh charts/certmanager.sh;
fi

printf "${GREEN}Finished setting up the Sugarizer School Portal Environment${NC}\n";

# Check for Sugarizer School Portal
sh charts/ssp.sh -p $provider -s $ssl;

printf "${GREEN}Finished setting up the Kubernetes cluster${NC}\n";

printf "\n${YELLOW}Note: Point the Address ${BLUE}('A')${YELLOW} Record of your Cloud DNS zone to the Cluster IP of the NGINX Ingress Controller.${NC}\n\n";
