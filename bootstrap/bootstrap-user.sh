#!/bin/bash

USER=$1
CICD_NS=$2

echo "Bootstraping user $USER (CI/CD ns=$CICD_NS)"

echo "Creating namespaces..."
cat ./ocp/ns/namespaces.yaml | USER=$USER envsubst | oc apply -f -

echo "Create self-contained user group"
cat ./ocp/groups/regular-user.yaml | USER=$USER envsubst | oc apply -f -

echo "Adding view role to ns=$CICD_NS"
cat ./ocp/rb/cicd-ns-rb.yaml | USER=$USER CICD_NS=$CICD_NS envsubst | oc apply -f -

echo "Adding admin role to its ns"
cat ./ocp/rb/user-admin.yaml | USER=$USER envsubst | oc apply -f -

echo "Adding system:image-puller from $USER-dev & $USER-prod ns to $USER ns"
cat ./ocp/rb/user-ns-image-puller.yaml| USER=$USER envsubst | oc apply -f -

echo "Creating ArgoCD AppProject for user ${USER}"
cat ./argocd/app-project.yaml | USER=$USER CICD_NS=$CICD_NS envsubst | oc apply -f -

echo "Adding ArgoCD Apps edit role for user ${USER}"
cat ./ocp/rb/argocd-apps-editor.yaml | USER=$USER CICD_NS=$CICD_NS envsubst | oc apply -f -