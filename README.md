# Service-dependencies NIX

## Build

```
nix-build --option sandbox false nix/build.nix
```

Can be run with

```shell
result/bin/service-dependencies -Dpidfile.path=/tmp/play.pid
```

## Docker

### App

```shell
nix-build --option sandbox false nix/docker.nix

docker load -i result
```

or all in one:
```shell
docker load -i $(nix-build --option sandbox false nix/docker.nix --no-out-link)
```

```shell
docker run -p 8459:8459 --hostname=127.0.0.1 --net=host service-dependencies:latest
```

Note `--hostname=127.0.0.1` required to avoid
```
java.net.UnknownHostException: 6b50343bca3f: 6b50343bca3f: Name or service not known
	at java.net.InetAddress.getLocalHost(InetAddress.java:1506)
```
(/etc/hosts looks fine)

Note `--net=host` to map localhost to host (for mongo)

Optionally overriding config
```shell
-e JAVA_OPTS=-Dmongodb.uri=mongodb://localhost:27017/service-dependencies
```

and test
```shell
curl -i "http://localhost:8459/ping/ping"
```

Stop with

```shell
docker ps
docker stop 7f5ea440ed09
```

### Mongo

```shell
nix-build nix/docker-mongo.nix
docker load -i result
docker run -p 27018:27017 --tmpfs /tmp -v /data/db mongodb:latest
```


## Deploy to kind (local k8s)

```shell
nix-shell --option sandbox false -A shell nix/k8s.nix
```

Port forward into cluster

```shell
kubectl get pods
kubectl port-forward svc/service-dependencies 7000:8459
curl -i "http://localhost:7000/ping/ping"
```


TODO
- Service can't access to mongo (currently on host)
  - requires a DNS CNAME mapping to localhost?
    https://cloud.google.com/blog/products/gcp/kubernetes-best-practices-mapping-external-services
    https://stackoverflow.com/questions/55164223/access-mysql-running-on-localhost-from-minikube
	https://stackoverflow.com/questions/53944826/can-not-connect-to-sql-server-database-hosted-on-localhost-from-kubernetes-how
- Setup port forwarding in k8s config?
  NodePort?
   https://www.bmc.com/blogs/kubernetes-services/
- `InetAddress.getLocalHost` usually fails with UnknownHostException - but not always.
  Required by ehcache.
  /etc/hosts is populated ok - timing issue - needs reloading?
