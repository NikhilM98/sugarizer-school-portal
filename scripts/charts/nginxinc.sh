#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e;

# Load colors
RED='\033[0;31m';
GREEN='\033[0;32m';
YELLOW='\033[0;33m';
BLUE='\033[0;34m';
NC='\033[0m';

while getopts s: flag
do
    case "${flag}" in
        s) ssl=${OPTARG};;
    esac
done

if [ -z ${ssl+x} ]; then # SSL is not set
    values='charts/nginxinc-values-https.yaml'; # Take HTTPS as default
elif [ "$ssl" = true ]; then # SSL is true
    values='charts/nginxinc-values-https.yaml';
elif [ "$ssl" = false ]; then # SSL is false
    values='charts/nginxinc-values-http.yaml';
else # SSL has unaccepted input
    printf "${RED}\nSetup Aborted | SSL (-s) has unaccepted input ${YELLOW}'$ssl'${RED}.\n${NC}";
    exit 1;
fi

printf "${YELLOW}Checking for NGINX Ingress Controller with releasename: ${BLUE}nginx-ingress\n${NC}";
helm status ingress-nginx >/dev/null 2>&1 || {
    printf >&2 "${BLUE}Chart not found. Installing NGINX Ingress Controller...\n${NC}";
    helm repo add nginx-stable https://helm.nginx.com/stable;
    helm repo update;
    helm install ingress-nginx nginx-stable/nginx-ingress -f $values;
}
printf "${GREEN}Finished checking for NGINX Ingress Controller\n\n${NC}";
