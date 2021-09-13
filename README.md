# BOXY Wallet in Docker Container

RPC Port = 8332
Port = 8333

## Building Process
* Update & install required packages.
* Compile depends folder.
* Compile wallet.
* Copy to fresh container.

## Build the docker image
```shell
docker build . -t <docker-hub-username>/boxycoin-core
```

## Testing with Docker
```shell
docker run -it -p 8332:8332 <docker-hub-username>/boxycoin-core
```

## Testing with skaffold
