#!/bin/bash

helm uninstall ssp reflector mymongodb ingress-nginx
helm repo remove ssp
helm repo remove nginx-stable
helm repo remove jetstack
kubectl delete namespace cert-manager
kubectl delete namespace schoolportal
