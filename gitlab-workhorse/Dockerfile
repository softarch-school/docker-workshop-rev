# GitLab Workhorse (part of GitLab CE)
#
# @see https://gitlab.com/gitlab-org/gitlab-ce/blob/master/doc/install/installation.md
# @see https://gitlab.com/gitlab-org/gitlab-workhorse


FROM golang:1.7.4
MAINTAINER William Yeh "william.pjyeh@gmail.com"


ENV GITLAB_WORKHORSE_URL https://gitlab.com/gitlab-org/gitlab-workhorse.git

RUN     mkdir -p /tmp/app
WORKDIR /tmp/app

RUN git clone $GITLAB_WORKHORSE_URL  && \
    cd gitlab-workhorse              && \
    make install


# gitlab-workhorse is installed to /usr/local/bin
WORKDIR /usr/local/bin
COPY    gitlab-workhorse-wrapper.sh  /usr/local/bin


EXPOSE 8181
VOLUME ["/home/git/gitlab/public"]

ENTRYPOINT ["gitlab-workhorse-wrapper.sh"]
#CMD ["gitlab-workhorse-wrapper.sh"]
#CMD ["gitlab-workhorse"]


#---
#CMD -listenUmask 0 -listenNetwork unix -listenAddr /home/git/gitlab/tmp/sockets/gitlab-workhorse.socket -authBackend http://127.0.0.1:8080 -authSocket /home/git/gitlab/tmp/sockets/gitlab.socket -documentRoot /home/git/gitlab/public
#---

CMD -authBackend http://127.0.0.1:8080 -documentRoot /home/git/gitlab/public -logFile /var/log/workhorse.log

