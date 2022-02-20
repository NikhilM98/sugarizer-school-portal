#!/bin/bash

helm uninstall ssp reflector mymongodb ingress-nginx
helm uninstall cert-manager --namespace=cert-manager
helm repo remove ssp
helm repo remove nginx-stable
helm repo remove jetstack
kubectl delete namespace cert-manager
kubectl delete namespace schoolportal
