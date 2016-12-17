# Customize PostgreSQL for GitLab
#
# @see https://hub.docker.com/_/postgres/
#

FROM postgres:9.6

COPY init-user-db.sql /docker-entrypoint-initdb.d/
