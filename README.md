# webMethods microservice showcase

This repo contains various assets to showcase the use of the webMethods Microservice Runtime (MSR) to implement a customer management microservice, which can be deployed in Kubernetes using a CI/CD pipeline.

## Logical architecture

![Logical architecture](./resources/images/LogicalArchitecture.png)

### Universal messaging (UM)

Universal messaging is used to implement the event driven architecture layer, which allows microservices to communicate in loosely coupled fashion using events and commands. The microservice publishes CustomerUpdate events that can be consumed by interested subscribers, following the publish/subscribe pattern.

Universal Messaging can be placed in any location that's accessible from the Kubernetes cluster, including inside the cluster.

### Database

The relational database simply stores customer information.

I'm pointing to an Azure management Postgres DB here. But any other location would do, as long as it's accessible from the Kubernetes cluster. Putting this DB inside the Kubernetes cluster is also a valid option.

### Microservice runtime (MSR)

The MSR is a lightweight distributed ESB, which exposes the microservice API, connects to all sorts of backend resources (including databases and messaging brokers), and deals with the mapping and transformation logic. It's the core component of our microservice.

It is deployed inside the Kubernetes cluster, within a deployment of pods.

### Microgateway and API gateway

API management is a usual concern in microservice architectures. We want a central point of governance for our microservices, dealing with access control, mediation, monitoring, documentation and possibly monetization.

Traditional API management relies on an API gateway, which works in a hub and spoke architecture. All flows transit through a central cluster. If you have several datacenters (or cloud regions) you can have several clusters of API gateways. But in a microservice architecture you would certainly not have one API gateway cluster for each microservice, it would be an overkill. Instead we use a microgateway.

The microgateway is another lightweight distributed component which focuses on API management. It's not an API gateway, its role is only to secure microservices' APIs at the source and forward API trafic logs to a central API gateway. We still have a central point of governance for our APIs (the central API gateway) but we have a multitude of distributed agents that sit near the microservices (in the Kubernetes cluster) and protect them.

The API gateway can be located anywhere, it just needs to be accessible from the Kubernetes cluster. Like the UM and the Database it can also be inside the Kubernetes cluster, but a serverless API Gateway will also be perfect for the job at hand.

### API consumer

There are two possible routes to consume the APIs exposed by the microservice:
-   direct calls to the microgateway
-   or calls to the central API gateway, which redirects the trafic to the microgateway in charge of protecting the microservice

The former approach is more distributed and robust, we can rely on all the benefits of Kubernetes: scalability, observability and repairability.
But while the microgateway deals with the API access control, it does not manage network threats like DDoS, SQL injection, poisonous XML/JSON payloads.
Most of these considerations can be managed by modern firewalls and applicative gateways. But in the absence of such network security components, making API consumers go through the API gateway becomes a sensible option.


## Repository contents

Refering to the logical architecture, this repository contains assets relating the microservice runtime and the microgateway.

We have:
- the content of the webMethods MSR package itself, which connects to the database, universal messaging and exposes the REST API
- the application.properties file, which allows the configuration of various MSR resources (JDBC adapter, JNDI & JMS settings, etc) using environment variables
- a Dockerfile together with its .dockerignore file, which serve to build the microservice image
- the REST API Swagger specification (Open API Specification v2) under resources/api
- the Docker deployment script under resources/deployment/docker
- the Kubernetes sidecar deployment manifest files under resources/deployment/kubernetes-side-car and resources/deployment/kubernetes (we have two deployment topologies to choose from)
- A Grafana report under resources/monitoring (which need to be reworked)
- Some assets for automated testing under resources/test
- Two CI/CD pipelines for Azure Pipelines azure-pipelines-sidecar.yml and azure-pipelines.yml, together with the scripts under resources/buildScripts

## Microservice implementation

![webMethods package layout](./resources/images/PackageLayout.png)

We follow the recommended layered approach:
- a customerCanonical document type defining the Customer object
- a jdbc folder containing the JDBC adapter services
- a service folder containing the flow services, which invoke the JDBC adapter services to access the database and use the Customer document type
- an API folder containing the REST API descriptor and the mapping between the API methods and the flow services

There's not much difference between an API implemented in the "traditional" Integration Server and one implemented in a Microservice Runtime. The microservice specificities are at configuration, packaging and deployment levels.

## Microservice external configuration

We want our image to be "environment agnostic". The very same image will go to QA, UAT and later Production.
Everything that is environment specific needs to be externalized: connection to backend APIs, databases, messaging brokers, etc.
Same principle for the operating properties, such as the log level.

The MSR lets us provide a properties files to inject everything that is environment specific into the microservice container.
There are two ways of providing this file to the container:
- it can be outside the image and mounted into the container
- or it can be inside the image and point to environment variables that are passed to the container when it is launched

We use the second option here.

In both cases, we need to pass the location of the properties file to the MSR container using the SAG_IS_CONFIG_PROPERTIES environment variable.

## Microservice build and push

A Dockerfile is provided to build the microservice container image.
The base image is staillansag/webmethods-microservicesruntime:10.15.0.2-jdbc, which I created myself. It's the base MSR image provided in https://containers/softwareag.com, to which I have added the WmJDBCAdapter package along with the required JAR drivers.

In the Dockerfile we copy the content of the github repo (the content of the webMethods package), two configuration files related to JNDI and JMS and a few configuration files related to the hybrid integration with webmethods.io

The Github repo also contains some assets that are not meant to be part of the Docker image, so we use a .dockerignore file to ensure we don't place things like the Kubernetes deployment manisfests, README pictures or CI/CD scripts into the image.

You would then push the image to any registry of your liking. It's a Docker image like any other.

## Microgateway configuration


## Docker deployment


## Kubernetes deployment

Two options exist to deploy the microgateway in the Kubernetes cluster.

### Side car deployment

![webMethods package layout](./resources/images/SidecarDeployment.png)

Each pods contains a microgateway container that sits next to the MSR container (hence the "sidecar" name.) The former is the only entry point to the API, the latter is never exposed to the "outside world."

It's the best deployment option to govern East - West traffic in the microservice architecture (API trafic between all the microservices.) Uncontrolled management of these dependencies can indeed severely impact the evolutivity of microservices.

### Microgateway and MSR as standalone deployments

![webMethods package layout](./resources/images/StandaloneDeployment.png)

Another deployment option is to have the microgateway and the microservice as standalone pod deployments.

While loosing the East - West governance capabilities, it creates opportunities to optimize the use of infrastructure resources. The microgateway and MSR can scale independently, and you could even decide to use your microgateway deployment to protect several microservices.

## Monitoring with Prometheus and Grafana


## Agregation of application logs using FluentD


## CI/CD with Azure Pipelines (and Newman for the automated tests)


## External dependencies

### Postgres database


### Universal messaging


### API gateway

