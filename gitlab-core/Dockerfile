# GitLab CE image, the core part.
#
# @see https://gitlab.com/gitlab-org/gitlab-ce/blob/master/doc/install/installation.md
#

FROM ruby:2.3.3
MAINTAINER William Yeh "william.pjyeh@gmail.com"

ENV GIT_VERSION          2.12.0
ENV GIT_TARBALL_URL      https://www.kernel.org/pub/software/scm/git/git-$GIT_VERSION.tar.gz
ENV GITLAB_VERSION       8-16-stable
ENV GITLAB_CE_URL=https://gitlab.com/gitlab-org/gitlab-ce.git

WORKDIR /tmp

RUN \
    echo "==> 1 - Packages / Dependencies"    && \
    apt-get update -y                         && \
    \
    echo "--> 1.2 - Install the required packages (needed to compile Ruby and native extensions to Ruby gems)"  && \
    apt-get install -y \
  build-essential zlib1g-dev libyaml-dev libssl-dev libgdbm-dev        \
  libreadline-dev libncurses5-dev libffi-dev curl openssh-server       \
  checkinstall libxml2-dev libxslt-dev libcurl4-openssl-dev libicu-dev \
  logrotate python-docutils pkg-config cmake nodejs  && \
    \
    echo "--> 1.3 - Remove old packaged Git"  && \
    apt-get remove git-core                   && \
    \
    echo "--> 1.4 - Install dependencies for compiling Git"  && \
    apt-get install -y libcurl4-openssl-dev libexpat1-dev gettext libz-dev libssl-dev build-essential  && \
    \
    echo "--> 1.5 - Download and compile Git from source"  && \
    curl --silent --remote-name $GIT_TARBALL_URL           && \
    tar -xzf git-$GIT_VERSION.tar.gz  && \
    cd git-$GIT_VERSION               && \
    ./configure                       && \
    make prefix=/usr/local all        && \
    \
    echo "--> 1.6 - Install Git into /usr/local/bin"  && \
    make prefix=/usr/local install  && \
    \
    echo "--> 1.7 - Clean up Git tarball"  && \
    cd /tmp                                && \
    rm -rf git-$GIT_VERSION*

RUN \
    echo "==> 8 - GitLab"  && \
    \
    echo "--> 8.1 - We'll install GitLab into home directory of the user 'git' "  && \
    mkdir -p /home/git  && \
    cd /home/git        && \
    \
    \
    echo "--> 8.2 - Clone GitLab repository"            && \
    git clone $GITLAB_CE_URL -b $GITLAB_VERSION gitlab  && \
    \
    \
    echo "--> 8.3 - Configure GitLab..."  && \
    \
    # Go to GitLab installation folder
    cd /home/git/gitlab  && \
    \
    # Copy the example GitLab config
    cp config/gitlab.yml.example config/gitlab.yml  && \
    \
    # Update GitLab config file, follow the directions at top of file
    sed -i -e 's/bin_path:.*/bin_path: \/usr\/local\/bin\/git/g'  config/gitlab.yml  && \
    \
    # Copy the example secrets file
    cp config/secrets.yml.example config/secrets.yml  && \
    chmod 0600 config/secrets.yml  && \
    \
    # Make sure GitLab can write to the log/ and tmp/ directories
    #chown -R git log/
    #chown -R git tmp/
    #chmod -R u+rwX,go-w log/
    #chmod -R u+rwX tmp/
    \
    # Make sure GitLab can write to the tmp/pids/ and tmp/sockets/ directories
    #sudo chmod -R u+rwX tmp/pids/
    #sudo chmod -R u+rwX tmp/sockets/
    \
    # Create the public/uploads/ directory
    mkdir public/uploads/  && \
    \
    # Make sure only the GitLab user has access to the public/uploads/ directory
    # now that files in public/uploads are served by gitlab-workhorse
    #sudo chmod 0700 public/uploads
    \
    # Change the permissions of the directory where CI build traces are stored
    #sudo chmod -R u+rwX builds/
    \
    # Change the permissions of the directory where CI artifacts are stored
    #sudo chmod -R u+rwX shared/artifacts/
    \
    # Copy the example Unicorn config
    cp config/unicorn.rb.example config/unicorn.rb  && \
    \
    # Find number of cores
    nproc  && \
    \
    # Enable cluster mode if you expect to have a high load instance
    # Set the number of workers to at least the number of cores
    # Ex. change amount of workers to 3 for 2GB RAM server
    ####sudo -u git -H editor config/unicorn.rb

    # Copy the example Rack attack config
    cp config/initializers/rack_attack.rb.example config/initializers/rack_attack.rb  && \
    \
    # Configure Git global settings for git user
    # 'autocrlf' is needed for the web editor
    git config --global core.autocrlf input  && \
    \
    # Disable 'git gc --auto' because GitLab already runs 'git gc' when needed
    git config --global gc.auto 0  && \
    \
    # Enable packfile bitmaps
    git config --global repack.writeBitmaps true  && \
    \
    # Configure Redis connection settings
    cp config/resque.yml.example config/resque.yml  && \
    \
    # Change the Redis socket path if you are not using the default Debian / Ubuntu configuration
    sed -i -e 's/localhost:6379/0.0.0.0:6379/g'  config/resque.yml  && \
    sed -i -e 's/  url:.*/  url: redis:\/\/0.0.0.0:6379/g'  config/resque.yml  && \
    \
    echo "--> 8.4 - Configure GitLab DB Settings"  && \
    \
    # PostgreSQL only:
    cp config/database.yml.postgresql config/database.yml  && \
    \
    # Make config/database.yml readable to git only
    #chmod o-rwx config/database.yml
    \
    echo "--> 8.5 - Install Gems"  && \
    # For PostgreSQL (note, the option says "without ... mysql")
    bundle install --deployment --without development test mysql aws kerberos

