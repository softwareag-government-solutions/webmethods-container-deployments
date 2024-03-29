# webmethods APIGateway and Developer 10.11, Clustered in Kubernetes - Using Helm Charts 

This page will walk through the deployment of a realistic scalable API Management 10.11 cluster in your kubernetes environment:

 - 2 API Gateway runtime servers (clustered)
 - 2 Developer portal servers (clustered)
 - 3 Elastic Search servers (clustered)

 ![Deployment](./images/deployment_goal.png)

# Table of contents

- [Prep steps](#prep-steps)
  - [1) Install Helm CLI, and Add the Software AG Government Solutions HelmChart](#1-install-helm-cli-and-add-the-software-ag-government-solutions-helmchart)
  - [2) Preps for Install of ElasticSearch/Kibana](#2-preps-for-install-of-elasticsearchkibana)
    - [2a) IF using Elastic Operator](#2a-if-using-elastic-operator)
    - [2b) IF using Elastic/Kibana Helm charts](#2b-if-using-elastickibana-helm-charts)
  - [3) Create demo namespace](#3-create-demo-namespace)
  - [4) Add pull secrets for the container images](#4-add-pull-secrets-for-the-container-images)
  - [5) Add secrets for the SoftwareAG products](#5-add-secrets-for-the-softwareag-products)
    - [5a) Add the SoftwareAG products licenses as secrets](#5a-add-the-softwareag-products-licenses-as-secrets)
    - [5b) Add Secrets for the API Gateway / Dev Portal admin passwords](#5b-add-secrets-for-the-api-gateway--dev-portal-admin-passwords)
- [Deploy/Detroy the full SoftwareAG API Management stack - Manual step-by-step](#deploydetroy-the-full-softwareag-api-management-stack---manual-step-by-step)
  - [1) Deploy ElasticSearch stack](#1-deploy-elasticsearch-stack)
    - [1a) IF using Elastic Operator](#1a-if-using-elastic-operator)
    - [1b) IF using Helm charts](#1b-if-using-helm-charts)
  - [2) Deploy Developer Portal stack (using helm)](#2-deploy-developer-portal-stack-using-helm)
  - [3) Deploy API Gateway stack (using helm)](#3-deploy-api-gateway-stack-using-helm)
  - [4) Deploy Configurator stacks (using helm)](#4-deploy-configurator-stacks-using-helm)
  - [Uninstall Steps](#uninstall-steps)
    - [1) Destroy APIMGT stack (API Gateway, Developer portal, and the configurators)](#1-destroy-apimgt-stack-api-gateway-developer-portal-and-the-configurators)
    - [2) Destroy ElasticSearch stack](#2-destroy-elasticsearch-stack)
      - [2a) IF using Elastic Operator](#2a-if-using-elastic-operator)
      - [2b) IF using Helm charts](#2b-if-using-helm-charts)
- [Deploy/Detroy the full SoftwareAG API Management stack - All-in-one Script](#deploydetroy-the-full-softwareag-api-management-stack---all-in-one-script)
  - [1) Deploy stack](#1-deploy-stack)
    - [1a) IF using Helm charts](#1a-if-using-helm-charts)
    - [1b) IF using Elastic Operator](#1b-if-using-elastic-operator)
  - [2) Destroy stack](#2-destroy-stack)
    - [2a) IF using Helm charts](#2a-if-using-helm-charts)
    - [2b) IF using Elastic Operator](#2b-if-using-elastic-operator)

---

## Prep steps

### 1) Install Helm CLI, and Add the Software AG Government Solutions HelmChart

We'll be using Helm to deploy the Software AG product stacks into our cluster.
The public *Softwareag Government Solutions Helm-Chart repo* is at: https://softwareag-government-solutions.github.io/saggov-helm-charts

<p align="center">
  <img src="./images/step1_helmcharts.png" alt="Step 1 in picture - Helm Chart Details" width="75%" />
</p>

So let's add the repo:

```bash
helm repo add saggov-helm-charts https://softwareag-government-solutions.github.io/saggov-helm-charts
helm repo update
```

### 2) Preps for Install of ElasticSearch/Kibana

#### 2a) IF using Elastic Operator

The sample deployment described in this page leverage the Elastic stack from Elastic.
For easy deployment of Elastic Search and Kibana, we'll be using the Elastic Kubernetes Operator called Elastic Cloud on Kubernetes (ECK).
Elastic Cloud on Kubernetes (ECK) is a Kubernetes operator to orchestrate Elastic applications (Elasticsearch, Kibana, APM Server, Enterprise Search, Beats, Elastic Agent, and Elastic Maps Server) on Kubernetes. 
See Elastic Cloud on Kubernetes (ECK) at https://www.elastic.co/guide/en/cloud-on-k8s/1.9/index.html for more details on that.

<p align="center">
  <img src="./images/step2_elastic_operator.png" alt="Step 2 in picture - Elastic Search Operator" width="75%" />
</p>

Installation Summary (version 1.9.1)
```bash
kubectl create -f https://download.elastic.co/downloads/eck/1.9.1/crds.yaml
kubectl apply -f https://download.elastic.co/downloads/eck/1.9.1/operator.yaml
```

#### 2b) IF using Elastic/Kibana Helm charts

All the elastic helm charts are at https://github.com/elastic/helm-charts

Add the helm chart repo for Elastic search:

```bash
helm repo add elastic https://helm.elastic.co
helm repo update
```

### 3) Create demo namespace

To keep things well contained, let's create a demo namespace for our deployed artifacts:

<p align="center">
  <img src="./images/step3_demo_namespace.png" alt="Step 3 in picture - New namespace" width="30%" />
</p>

```bash
export NAMESPACE=apimgt-cluster-demo
kubectl create ns $NAMESPACE
kubectl config set-context --current --namespace=$NAMESPACE
```

### 4) Add pull secrets for the container images

The container images in our GitHub Container Registry are not publically accessible. Upon access granted, you'll need to add your auth_token into a K8s secret entry for proper image pulling...

<p align="center">
  <img src="./images/step4_github_auth_secret.png" alt="Step 4 in picture - Adding Github authentication secret" width="60%" />
</p>

Here it the command:

```bash
kubectl create secret docker-registry saggov-ghcr --docker-server=ghcr.io/softwareag-government-solutions --docker-username=mygithubusername --docker-password=mygithubreadtoken --docker-email=mygithubemail
```

where: 
mygithubusername = your github username
mygithubreadtoken = your github auth token with read access to the registry
mygithubemail = your github email

### 5) Add secrets for the SoftwareAG products

<p align="center">
  <img src="./images/step5_application_secets.png" alt="Step 5 in picture - Add secrets for the SoftwareAG products" width="60%" />
</p>

#### 5a) Add the SoftwareAG products licenses as secrets

Each product require a valid license to operate. We'll add the valid licenses in K8s secrets so they can be used by the deployments.

First, download and copy the licenses into the following ./licensing directory:
 - ApiGateway Advanced
   - expected filename: "./licensing/apigateway-license.xml"
 - Developer Portal
   - expected filename: "./licensing/devportal-license.xml"

NOTE: Make sure to use the expected file name for the next "create secret" command to work.

```bash
kubectl create secret generic softwareag-apimgt-licenses \
  --from-file=apigateway-license=./licensing/apigateway-license.xml \
  --from-file=devportal-license=./licensing/devportal-license.xml
```

#### 5b) Add Secrets for the API Gateway / Dev Portal admin passwords

Let's create the secrets for the Administrator's passwords (API Gateway and Dev Portal)

API Gateway:

```bash
echo -n "Desired/New Administrator password: "; read -s password; export ADMIN_PASSWORD=$password
echo -n "Default/Old Administrator password: "; read -s passwordOld; export ADMIN_PASSWORD_OLD=$passwordOld
kubectl create secret generic softwareag-apimgt-apigateway-passwords --from-literal=Administrator=$ADMIN_PASSWORD --from-literal=AdministratorOld=$ADMIN_PASSWORD_OLD
```

Developer Portal:

```bash
echo -n "Desired/New Administrator password: "; read -s password; export ADMIN_PASSWORD=$password
echo -n "Default/Old Administrator password: "; read -s passwordOld; export ADMIN_PASSWORD_OLD=$passwordOld
kubectl create secret generic softwareag-apimgt-devportal-passwords --from-literal=Administrator=$ADMIN_PASSWORD --from-literal=AdministratorOld=$ADMIN_PASSWORD_OLD
```

---

## Deploy/Detroy the full SoftwareAG API Management stack - Manual step-by-step

### 1) Deploy ElasticSearch stack

#### 1a) IF using Elastic Operator

NOTE: The command below rely on Elastic Cloud on Kubernetes (ECK) available and installed in the cluster. See section "Add Elastic Operator to Kubernetes cluster (if not there alteady)" for details on that.

Once ECK is installed, simply run the following 2 commands to install the elastic stack:

```bash
kubectl --namespace $NAMESPACE apply -f ./descriptors/elastic_operator/elasticsearch.yaml
kubectl --namespace $NAMESPACE apply -f ./descriptors/elastic_operator/kibana.yaml
```

#### 1b) IF using Helm charts

```bash
helm upgrade -i --namespace $NAMESPACE -f ./descriptors/helm/elasticseach.yaml --version 7.14.0 elasticsearch elastic/elasticsearch
helm upgrade -i --namespace $NAMESPACE -f ./descriptors/helm/kibana.yaml --version 7.14.0 kibana elastic/kibana
```

### 2) Deploy Developer Portal stack (using helm)

```bash
helm upgrade -i --namespace $NAMESPACE -f ./descriptors/helm/devportal.yaml devportal saggov-helm-charts/webmethods-devportal
```

### 3) Deploy API Gateway stack (using helm)

```bash
helm upgrade -i --namespace $NAMESPACE -f ./descriptors/helm/apigateway.yaml apigateway saggov-helm-charts/webmethods-apigateway
```

### 4) Deploy Configurator stacks (using helm)

```bash
helm upgrade -i --namespace $NAMESPACE -f ./descriptors/helm/apigateway-configurator.yaml webmethods-apigateway-configurator saggov-helm-charts/webmethods-apigateway-configurator
helm upgrade -i --namespace $NAMESPACE -f ./descriptors/helm/devportal-configurator.yaml webmethods-devportal-configurator saggov-helm-charts/webmethods-devportalconfigurator
```

### Uninstall Steps

#### 1) Destroy APIMGT stack (API Gateway, Developer portal, and the configurators)

```bash
helm uninstall --namespace $NAMESPACE webmethods-apigateway-configurator
helm uninstall --namespace $NAMESPACE webmethods-devportal-configurator

helm uninstall --namespace $NAMESPACE apigateway
helm uninstall --namespace $NAMESPACE devportal
```

#### 2) Destroy ElasticSearch stack

##### 2a) IF using Elastic Operator

```bash
kubectl --namespace $NAMESPACE delete -f ./descriptors/elastic_operator/elasticsearch.yaml
kubectl --namespace $NAMESPACE delete -f ./descriptors/elastic_operator/kibana.yaml
```

##### 2b) IF using Helm charts

```bash
helm uninstall --namespace $NAMESPACE kibana
helm uninstall --namespace $NAMESPACE elasticsearch
```

---

## Deploy/Detroy the full SoftwareAG API Management stack - All-in-one Script

### 1) Deploy stack

#### 1a) IF using Helm charts

```bash
/bin/sh deploy.sh $NAMESPACE
```

#### 1b) IF using Elastic Operator

```bash
/bin/sh deploy_with_elastic_operator.sh $NAMESPACE
```

### 2) Destroy stack

#### 2a) IF using Helm charts

```bash
/bin/sh destroy.sh $NAMESPACE
```

#### 2b) IF using Elastic Operator

```bash
/bin/sh destroy_with_elastic_operator.sh $NAMESPACE
```
