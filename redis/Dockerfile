# dockerize `redis-server`

FROM scratch

ADD  rootfs.tar.gz  /
COPY redis.conf     /etc/redis/redis.conf

# Redis port.
EXPOSE 6379


ENTRYPOINT ["redis-server"]
CMD ["/etc/redis/redis.conf"]
