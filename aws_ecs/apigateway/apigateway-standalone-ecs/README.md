# webmethods ApiGateway in AWS Elastic Container Server (ECS) by Software AG Government Solutions 

Sample deployments to AWS ECS

## Pre-requisite 1: Push images to ECR

First, let's push our images to the AWS Elastic Container Registry (ECR).

Do do so:

1) login to ECR:

```
export REGION=us-east-1
export REGISTRY=some_ecr_registry
```

```
aws ecr get-login-password --region ${REGION} | docker login --username AWS --password-stdin ${REGISTRY}
```

2) Build the images:

```
docker-compose -f docker-compose-build.yml build
```

2) Create the repos in AWS ECR

Create the 2 needed repos in ECR:
- webmethods-apigateway-reverseproxy
- webmethods-apigateway-standalone

3) Push the images:

```
docker-compose -f docker-compose-build.yml push
```

## Pre-requisite 2: Create Docker ECS content

TODO

## Load the deployment into ECS using compose

Simply run:

```
docker compose up -d
```

Note: if you want to check out the AWS cloud formation generated from the docker-compose (or if you want to add the cloudformation template by yourself in AWS), run:

```
docker compose convert
```