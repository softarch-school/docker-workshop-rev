# Redis server (minimal Docker image)

Extracted from my previous talk "[Quest for minimal Docker images](https://github.com/William-Yeh/docker-mini)", Lab 05.

  - Slide: [Lab #05 - Extract dynamically-linked .so files](http://william-yeh.github.io/docker-mini/#38)


Read it for more information.

## Build

```bash
docker  build  -t redis-mini:3.0.0  .
```

## List images

```bash
docker images

dockviz images --tree
```

## Run

```bash
docker run  --name redis-01  -P  redis-mini
```

## List containers

```bash
docker ps
```

## Inspect containers

```bash
docker inspect redis-01
```

## Test

```bash
redis-cli  -p <port_number>
```
