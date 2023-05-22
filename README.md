# webmethods microservice showcase

This repo contains various assets to showcase the use of the webMethods Microservice Runtime (MSR) to implement a customer management microservice.
The microservice exposes a REST API that is relayed and secured by the webMethods microgateway.
It also publishes an event to a Universal Messaging JMS destination each time a customer is updated through the API, so that interested applications (subscribers) are made aware of the changes.



We have:
- the content of the webMethods package itself
- the application.properties file, which allows the configuration of various MSR resources (JDBC adapter, JNDI & JMS settings, etc) using environment variables
- a Dockerfile together with its .dockerignore file, which serve to build the microservice image
- the API Swagger specification (Open API Specification v2) under resources/api
- the Docker deployment script under resources/deployment/docker
- the Kubernetes sidecar deployment manifest files under resources/deployment/kubernetes-side-car
- Kubernetes manifest files with the other deployment option that exists, in which the Microgateway and the MSR each have their own deployment & service
- A Grafana report under resources/monitoring (which need to be reworked)
- Some assets for automated testing under resources/test
- Two CI/CD pipelines for Azure Pipelines azure-pipelines-sidecar.yml and azure-pipelines.yml, together with the scripts under resources/buildScripts


