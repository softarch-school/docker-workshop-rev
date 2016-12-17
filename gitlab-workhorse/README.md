# GitLab Workhorse image


## Build

### Utilize official Golang image 1.7.4

From: [Official Golang image](https://hub.docker.com/_/golang/)

Image: `golang:1.7.4`
Dockerfile: [1.7.4](https://github.com/docker-library/golang/blob/2372c8cafe9cc958bade33ad0b8b54de8869c21f/1.7/Dockerfile)



### Build the GitLab Workhorse


```bash
docker build  -t gitlab-workhorse  .
```

## Run


```bash
docker run  -it -P  gitlab-workhorse  -authBackend http://127.0.0.1:10080
```




## Key concepts

### Layers


### Selection of base images

Consider pros and cons for each of the following selection:

1. Zero (i.e., `scratch`).

2. Minimal base image (e.g., `alpine`).

3. OS base image (e.g., `debian:jessie`).

4. Normal Golang base image (e.g., `golang:1.7.4`).

5. Onbuild Golang base image (e.g., `golang:1.7.4-onbuild`).



### Wrapper script

- Why wrapper here?

- Dockerfile: `CMD` vs `ENTRYPOINT`.



### Volume

Read the following articles:

- [Manage data in containers](https://docs.docker.com/engine/tutorials/dockervolumes/) from Docker Inc

- [How To Work with Docker Data Volumes on Ubuntu 14.04](https://www.digitalocean.com/community/tutorials/how-to-work-with-docker-data-volumes-on-ubuntu-14-04) from DigitalOcean

- [Docker best practices: data and stateful applications](https://getcarina.com/docs/best-practices/docker-best-practices-data-stateful-applications/)



