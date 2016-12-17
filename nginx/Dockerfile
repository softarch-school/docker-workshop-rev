# Inherit from official nginx:1.10.2,
# and customize it for GitLab Workhorse.

FROM nginx:1.10.2
MAINTAINER William Yeh "william.pjyeh@gmail.com"


# remove unused "default.conf"
RUN  rm -f /etc/nginx/conf.d/*
#COPY gitlab.conf  /etc/nginx/conf.d/gitlab.conf


#EXPOSE 80 443
VOLUME ["/etc/nginx/conf.d"]

#CMD ["nginx", "-g", "daemon off;"]
