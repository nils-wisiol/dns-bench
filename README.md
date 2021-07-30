# DNS Workbench

This repository contains a authoritative name server and a validating resolver and can be used to study resolver
behavior for names under `bench.pqdnssec.dedyn.io`.


## Getting Started

Install docker and docker-compose. Then run

```shell
docker-compose build
docker-compose up -d
```

Check the status of the containers with

```shell
docker-compose ps
```

Allow a couple of seconds for MariaDB to spin up.

## Authoritative Zone Information

After the system is started and ready to use, use the [included script](auth/init-zone.sh) to initialize the server
with DNS information:

```shell
docker-compose exec auth bash init-zones
```

The authoritative name server is equipped with a zone under the name of `bench.pqdnssec.dedyn.io`.
As the DS record for this zone is hosted upstream by desec.io, the private key is part of this repository.
There are two additional zones which are delegated appropriately: `baseline.bench.pqdnssec.dedyn.io` and
`falcon.bench.pqdnssec.dedyn.io`.
While the latter is intended to use the Falcon signature scheme later, both currently use ed448.

TODO: Upgrade to actually use Falcon.

Data served by the authoritative name server is kept across restarts, unless the database volume is deleted.

TODO: Add info on how to add broken DNSSEC, add info on how to use different algorithm.

### Modify Zone Information

The usual pdns CLI can be used, e.g., to set an additional A record at the zone `$Z`, use

```shell
docker-compose exec auth pdnsutil add-record $Z @ A 9.9.9.9
```


## Send Queries

To query the authoritative name server directly, use port 5300 like so:

```shell
dig @localhost -p 5300 +dnssec baseline.bench.pqdnssec.dedyn.io.
```

To query the resolver and get a validated answer, use port 5301 like so:

```shell
dig @localhost -p 5301 +dnssec baseline.bench.pqdnssec.dedyn.io.
```

To query the resolver without validation, use the `+cd` flag:

```shell
dig @localhost -p 5301 +dnssec TXT baseline.bench.pqdnssec.dedyn.io. +cd
```


## Background

The zone `pqdnssec.dedyn.io` contains NS records pointing to the private IP address 172.20.0.3 for queries under
`bench.pqdnssec.dedyn.io`.
This directs the recursor to contact the authoritative name server for queries under that name.
