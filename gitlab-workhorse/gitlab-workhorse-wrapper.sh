#!/bin/bash
#
# Simple wrapper for "gitlab-workhorse" executable.
#
# Example cmdline args:
#   -listenUmask 0 -listenNetwork unix -listenAddr /home/git/gitlab/tmp/sockets/gitlab-workhorse.socket -authBackend http://127.0.0.1:8080 -authSocket /home/git/gitlab/tmp/sockets/gitlab.socket -documentRoot /home/git/gitlab/public
#
#

# finally, actual work here!
exec  gitlab-workhorse  "$@"
