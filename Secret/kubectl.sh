#!/bin/bash

# create "secret" by using kubectl
kubectl create secret tls tls-secret --cert=path/to/tls.crt --key=path/to/tls.key
kubectl create secret generic mysql --from-literal=password=root

# Verify the Secret is Loaded
kubectl exec app-with-secret --printenv DB_USERNAME DB_PASSWORD

# encode your "word" with base64
echo -n PASSWORD | base64