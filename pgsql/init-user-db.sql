-- Setup DB for GitLab CE
-- @see https://gitlab.com/gitlab-org/gitlab-ce/blob/master/doc/install/installation.md



--> 5.2 - Create a database user for GitLab
--CREATE USER gitlab CREATEDB;

--> 5.3 - Create the pg_trgm extension (required for GitLab 8.6+)
CREATE EXTENSION IF NOT EXISTS pg_trgm;

--> 5.4 - Create the GitLab production database and grant all privileges on database
--CREATE DATABASE gitlabhq_production OWNER gitlab;
