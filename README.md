# webMethods microservice showcase

This repo contains various assets to showcase the use of the webMethods Microservice Runtime (MSR) to implement a customer management microservice, which can then be deployed in Kubernetes using a CI/CD pipeline.

The content of this repository needs to be placed in the packages folder of your MSR installation, in a directory called CustomerManagement
```
git clone https://github.com/staillansag/msr-customer-management-v2.git <msrInstallationPath>/packages/CustomerManagement
```

[Repository structure](./resources/documentation/RepositoryContents.md)

[Logical architecture](./resources/documentation/LogicalArchitecture.md)

[External dependencies (in progress)](./resources/documentation/ExternalDependencies.md)

[Development environment setup](./resources/documentation/DevelopmentEnvironmentSetup.md)

[Microservice implementation](./resources/documentation/MicroserviceImplementation.md)

[Microgateway implementation (todo)](./resources/documentation/Microgateway.md)

[Running the microservice in Docker (todo)](./resources/documentation/DockerDeployment.md)

[Running the microservice in Azure Kubernetes Service](./resources/documentation/AKSDeployment.md)

[Microservice monitoring (todo)](./resources/documentation/Monitoring.md)

[CI/CD with Azure Pipelines](./resources/documentation/CICD.md)
