# Nginx image


## Build

### Official Nginx image 1.10.2

From: [Official Nginx image](https://hub.docker.com/_/nginx/)
Dockerfile: [1.10.2](https://github.com/nginxinc/docker-nginx/blob/25a3fc7343c6916fce1fba32caa1e8de8409d79f/stable/jessie/Dockerfile)

```bash
docker build  -t nginx:1.10.2  -f Dockerfile.official-1.10.2  .
```

### Customized/derived Nginx image for GitLab Workhorse


```bash
docker build  -t my-nginx  .
```



## Key concepts


### Why "daemon off" in the official Nginx image?

See [http://william-yeh.github.io/docker-workshop/slides/dockerize.html](Lab 11: Dockerized app 必要條件).


### Layer


