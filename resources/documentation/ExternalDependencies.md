# External dependencies

The microservice has several external dependencies.
if you want to run it in your local environment or your own Kubernetes cluster, you need to manage the following setup.

## Postgres database

I am using an Azure Database for PostgreSQL flexible server with the following configuration: Burstable, B1ms, 1 vCores, 2 GiB RAM, 32 GiB storage.
But you can use any Postgres database, as long as it's accessible from a network standpoint.

You need to create a sandbox database, connect ot it and apply the following DDL to create the customers table.

```
CREATE TABLE public.customers (
	id varchar(100) NOT NULL,
	lastname varchar(100) NOT NULL,
	firstname varchar(100) NULL,
	birthdate date NULL,
	status bpchar(20) NULL,
	phonenumber varchar(50) NULL,
	email varchar(100) NOT NULL,
	CONSTRAINT customers_pk PRIMARY KEY (id),
	CONSTRAINT customers_un UNIQUE (email)
);
```

## Universal messaging

I'm using a single node UM that's deployed in a Docker host assessible from the internet.
It's exposing a Universal Messaging HTTP interface (nhp.)
On top of it I have a reverse proxy that manages TLS termination.

### Creation of the Docker network

My UM node and my reverse proxy are both deployed in the Docker host. So they can communicate using an internal Docker network.

```
docker create network sag
```

### Creation of the UM node

The deployment of UM using Docker is [documented here](https://containers.softwareag.com/products/universalmessaging-server) 

I am using this command, which places the container in the sag Docker network.

```
docker run -d -p 9000:9000 --name umcontainer --network sag sagcr.azurecr.io/universalmessaging-server:10.15
```

### Creation and configuration of the reverse proxy


### Configuration of the UM node

By default the UM exposes a nhp interface at port 9000.

You need to configure a XA connection factory named um_cf_xa_nhps and associated the url (RNAME) nhps://<node.external.domain.name>:443 where node.external.domain.name is the domain name exposed by your reverse proxy.


### Hardeming of the UM

You can harden this UM configuration by forcing basic authentication and / or by configuring mTLS.

## API gateway

The microgateway fetches its configuration by calling an API gateway deployed in the Software AG iPaaS. But it can work the same way with an API gateway deployed on-premise or in a IaaS infrastructure, as long as it's accessible from a network standpoint.

In the API gateway there needs to be an API proxy named CustomersAPI. The microgateway is configured to look for this proxy.