#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e;

# Load colors
RED='\033[0;31m';
GREEN='\033[0;32m';
YELLOW='\033[0;33m';
BLUE='\033[0;34m';
NC='\033[0m';

while getopts s:p: flag
do
    case "${flag}" in
        s) ssl=${OPTARG};;
        p) provider=${OPTARG};;
    esac
done

cmd="helm install ssp ssp/school-portal-chart --version 0.3.3 -f charts/ssp-values.yaml";

if [ -z ${provider+x} ]; then # provider is not set
    printf "${YELLOW}\nProvider (-p) is not set | Taking the value of Provider from ${BLUE}'ssp-values.yaml'${YELLOW}.\n${NC}";
elif [ "$provider" = "gke" ]; then # provider is set to gke
    cmd="$cmd --set cluster.provider=gke";
elif [ "$provider" = "azure" ]; then # provider is set to azure
    cmd="$cmd --set cluster.provider=azure";
elif [ "$provider" = "aws" ]; then # provider is set to aws
    cmd="$cmd --set cluster.provider=aws";
else # provider has unaccepted input
    printf "${RED}\nSetup Aborted | Provider (-p) has unaccepted input ${YELLOW}'$provider'${RED}.\n${NC}";
    exit 1;
fi

if [ -z ${ssl+x} ]; then # SSL is not set
    printf "${YELLOW}\nSSL (-s) is not set | Taking the value of SSL from ${BLUE}'ssp-values.yaml'${YELLOW}.\n${NC}";
elif [ "$ssl" = true ]; then # SSL is true
    cmd="$cmd --set deployment.https=true";
elif [ "$ssl" = false ]; then # SSL is false
    cmd="$cmd --set deployment.https=false";
else # SSL has unaccepted input
    printf "${RED}\nSetup Aborted | SSL (-s) has unaccepted input ${YELLOW}'$ssl'${RED}.\n${NC}";
    exit 1;
fi

printf "\n${YELLOW}Checking for Sugarizer-School-Portal with releasename: ${BLUE}ssp\n${NC}";
helm status sspa >/dev/null 2>&1 || {
    printf >&2 "${BLUE}Chart not found. Sugarizer-School-Portal needs to be installed.\n${NC}";

    printf "\n${YELLOW}The setup is paused.\n"${NC};
    printf "\n${YELLOW}Navigate to the ${BLUE}scripts/charts${YELLOW} directory and update the chart's ${BLUE}'ssp-values.yaml'${YELLOW} file.\n${NC}";
    printf "\n${YELLOW}After editing the ${BLUE}'ssp-values.yaml'${YELLOW} file, press Enter to continue setup or press Ctrl+C to exit setup...\n${NC}";

    read null;

    printf "${BLUE}Installing Sugarizer-School-Portal...\n${NC}";
    helm repo add ssp https://nikhilm98.github.io/sugarizer-school-portal-chart/;
    helm repo update;
    eval $cmd;
    printf "${GREEN}Sugarizer School Portal Chart has been installed with the release name: ${BLUE}ssp\n${NC}";
}
printf "${GREEN}Finished checking for Sugarizer-School-Portal\n\n${NC}";
