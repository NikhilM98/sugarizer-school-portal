#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e;

# Load colors
RED='\033[0;31m';
GREEN='\033[0;32m';
YELLOW='\033[0;33m';
BLUE='\033[0;34m';
NC='\033[0m';

printf "${YELLOW}Checking for MongoDB-Replicaset with releasename: ${BLUE}ssp-mongodb\n${NC}";
helm status ssp-mongodb >/dev/null 2>&1 || {
    printf >&2 "${BLUE}Chart not found. Installing MongoDB-Replicaset...\n${NC}";
    helm repo add bitnami https://charts.bitnami.com/bitnami;
    helm repo update;
    helm install ssp-mongodb bitnami/mongodb -f charts/mongodb-values.yaml;
}
printf "${GREEN}Finished checking for MongoDB-Replicaset\n\n${NC}";
