#!/bin/bash
#
# Install GitLab CE
# @see https://gitlab.com/gitlab-org/gitlab-ce/blob/master/doc/install/installation.md
# @see https://gitlab.com/gitlab-org/gitlab-workhorse
#


# Constants

GIT_VERSION=2.12.0
#GIT_VERSION=2.8.4
GIT_TARBALL_URL=https://www.kernel.org/pub/software/scm/git/git-$GIT_VERSION.tar.gz
RUBY_VERSION=2.3.3
RUBY_TARBALL_URL=https://cache.ruby-lang.org/pub/ruby/ruby-$RUBY_VERSION.tar.gz
GO_VERSION=1.7.4
GITLAB_VERSION=8-16-stable




echo "==> 1 - Packages / Dependencies"


echo "--> 1.1 - sudo"
# run as root!
apt-get update -y
#apt-get upgrade -y
apt-get install sudo -y


echo "--> 1.2 - Install the required packages (needed to compile Ruby and native extensions to Ruby gems)"
sudo apt-get install -y \
  build-essential zlib1g-dev libyaml-dev libssl-dev libgdbm-dev        \
  libreadline-dev libncurses5-dev libffi-dev curl openssh-server       \
  checkinstall libxml2-dev libxslt-dev libcurl4-openssl-dev libicu-dev \
  logrotate python-docutils pkg-config cmake nodejs


echo "--> 1.3 - Remove old packaged Git"
sudo apt-get remove git-core

echo "--> 1.4 - Install dependencies for compiling Git"
sudo apt-get install -y libcurl4-openssl-dev libexpat1-dev gettext libz-dev libssl-dev build-essential

echo "--> 1.5 - Download and compile Git from source"
cd /tmp
curl --silent --remote-name $GIT_TARBALL_URL
tar -xzf git-$GIT_VERSION.tar.gz
cd git-$GIT_VERSION
./configure
make prefix=/usr/local all

echo "--> 1.6 - Install Git into /usr/local/bin"
sudo make prefix=/usr/local install

echo "--> 1.7 - Clean up Git tarball"
cd /tmp
sudo rm -rf git-$GIT_VERSION*



echo "===================================================================="
echo "==> 2 - Ruby"

echo "--> 2.1 - Remove the old Ruby 1.8 if present"
sudo apt-get remove ruby1.8

echo "--> 2.2 - Download Ruby and compile it"
mkdir /tmp/ruby  &&  cd /tmp/ruby
curl --silent --remote-name $RUBY_TARBALL_URL
tar zxvf ruby-$RUBY_VERSION.tar.gz
cd ruby-$RUBY_VERSION
./configure --disable-install-rdoc
make
sudo make install

echo "--> 2.3 - Install the Bundler Gem"
sudo gem install bundler --no-ri --no-rdoc



echo "===================================================================="
echo "==> 3 - Go"

echo "--> 3.1 - Remove former Go installation folder"
sudo rm -rf /usr/local/go

curl --silent --remote-name https://storage.googleapis.com/golang/go$GO_VERSION.linux-amd64.tar.gz
sudo tar -C /usr/local -xzf go$GO_VERSION.linux-amd64.tar.gz
sudo ln -sf /usr/local/go/bin/{go,godoc,gofmt} /usr/local/bin/
rm go$GO_VERSION.linux-amd64.tar.gz



echo "===================================================================="
echo "==> 4 - Node.js"

echo "--> 4.1 - install node v7.x"
curl --silent https://deb.nodesource.com/setup_7.x | bash -
sudo apt-get install -y nodejs

echo "--> 4.2 - install yarn"
curl --silent https://yarnpkg.com/install.sh | bash -



echo "===================================================================="
echo "==> 5 - System Users"

echo "--> 5.1 - Create a git user for GitLab"
sudo adduser --disabled-login --gecos 'GitLab' git



echo "===================================================================="
echo "==> 6 - Database"


echo "--> 6.1 - Install the database packages"
sudo apt-get install -y postgresql postgresql-client libpq-dev postgresql-contrib

echo "--> 6.2 - Create a database user for GitLab"
sudo -u postgres psql -d template1 -c "CREATE USER git CREATEDB;"

echo "--> 6.3 - Create the pg_trgm extension (required for GitLab 8.6+)"
sudo -u postgres psql -d template1 -c "CREATE EXTENSION IF NOT EXISTS pg_trgm;"

echo "--> 6.4 - Create the GitLab production database and grant all privileges on database"
sudo -u postgres psql -d template1 -c "CREATE DATABASE gitlabhq_production OWNER git;"

#echo "--> 6.5 - Try connecting to the new database with the new user,"
#echo "-->       and Check if the pg_trgm extension is enabled"



echo "===================================================================="
echo "==> 7 - Redis"

echo "--> 7.1 - GitLab requires at least Redis 2.8."
sudo apt-get install -y redis-server


echo "===================================================================="
echo "==> 8 - GitLab"

echo "--> 8.1 - We'll install GitLab into home directory of the user 'git' "
cd /home/git


echo "--> 8.2 - Clone GitLab repository"
sudo -u git -H git clone https://gitlab.com/gitlab-org/gitlab-ce.git -b $GITLAB_VERSION gitlab


echo "--> 8.3 - Configure GitLab..."

# Go to GitLab installation folder
cd /home/git/gitlab

# Copy the example GitLab config
sudo -u git -H cp config/gitlab.yml.example config/gitlab.yml

# Update GitLab config file, follow the directions at top of file
sudo -u git -H sed -i -e 's/bin_path:.*/bin_path: \/usr\/local\/bin\/git/g'  config/gitlab.yml

# Copy the example secrets file
sudo -u git -H cp config/secrets.yml.example config/secrets.yml
sudo -u git -H chmod 0600 config/secrets.yml

# Make sure GitLab can write to the log/ and tmp/ directories
sudo chown -R git log/
sudo chown -R git tmp/
sudo chmod -R u+rwX,go-w log/
sudo chmod -R u+rwX tmp/

# Make sure GitLab can write to the tmp/pids/ and tmp/sockets/ directories
sudo chmod -R u+rwX tmp/pids/
sudo chmod -R u+rwX tmp/sockets/

# Create the public/uploads/ directory
sudo -u git -H mkdir public/uploads/

# Make sure only the GitLab user has access to the public/uploads/ directory
# now that files in public/uploads are served by gitlab-workhorse
sudo chmod 0700 public/uploads

# Change the permissions of the directory where CI build traces are stored
sudo chmod -R u+rwX builds/

# Change the permissions of the directory where CI artifacts are stored
sudo chmod -R u+rwX shared/artifacts/

# Copy the example Unicorn config
sudo -u git -H cp config/unicorn.rb.example config/unicorn.rb

# Find number of cores
nproc

# Enable cluster mode if you expect to have a high load instance
# Set the number of workers to at least the number of cores
# Ex. change amount of workers to 3 for 2GB RAM server
####sudo -u git -H editor config/unicorn.rb

# Copy the example Rack attack config
sudo -u git -H cp config/initializers/rack_attack.rb.example config/initializers/rack_attack.rb

# Configure Git global settings for git user
# 'autocrlf' is needed for the web editor
sudo -u git -H git config --global core.autocrlf input

# Disable 'git gc --auto' because GitLab already runs 'git gc' when needed
sudo -u git -H git config --global gc.auto 0

# Enable packfile bitmaps
sudo -u git -H git config --global repack.writeBitmaps true

# Configure Redis connection settings
sudo -u git -H cp config/resque.yml.example config/resque.yml

# Change the Redis socket path if you are not using the default Debian / Ubuntu configuration
sudo -u git -H sed -i -e 's/localhost:6379/0.0.0.0:6379/g'  config/resque.yml
sudo -u git -H sed -i -e 's/  url:.*/  url: redis:\/\/0.0.0.0:6379/g'  config/resque.yml



echo "--> 8.4 - Configure GitLab DB Settings"

# PostgreSQL only:
sudo -u git cp config/database.yml.postgresql config/database.yml

# Make config/database.yml readable to git only
sudo -u git -H chmod o-rwx config/database.yml


echo "--> 8.5 - Install Gems"
# For PostgreSQL (note, the option says "without ... mysql")
sudo -u git -H bundle install --deployment --without development test mysql aws kerberos


echo "--> 8.6 - Install GitLab Shell"
# Run the installation task for gitlab-shell (replace `REDIS_URL` if needed):
###sudo -u git -H bundle exec rake gitlab:shell:install REDIS_URL=unix:/var/run/redis/redis.sock RAILS_ENV=production SKIP_STORAGE_VALIDATION=true
sudo -u git -H bundle exec rake gitlab:shell:install REDIS_URL=redis://127.0.0.1:6379 RAILS_ENV=production SKIP_STORAGE_VALIDATION=true

# fix URL of GitLab API
sudo -u git -H sed -i -e 's/^gitlab_url:.*/gitlab_url: http:\/\/localhost:8080\//g'  /home/git/gitlab-shell/config.yml


echo "--> 8.7 - Install gitlab-workhorse"

#cd /home/git/gitlab
#sudo gem install haml_lint
#sudo -u git -H bundle exec rake "gitlab:workhorse:install[/home/git/gitlab-workhorse]" RAILS_ENV=production


# @see https://gitlab.com/gitlab-org/gitlab-workhorse
# @see http://widerin.net/blog/maintaining-manual-gitlab-installation-with-ansible/
cd /home/git
sudo -u git -H git clone https://gitlab.com/gitlab-org/gitlab-workhorse.git gitlab-workhorse
cd /home/git/gitlab-workhorse
sudo make install



echo "--> 8.8 - Initialize Database and Activate Advanced Features"
cd /home/git/gitlab

# set the Administrator/root password
echo "yes" | sudo -u git -H bundle exec rake gitlab:setup RAILS_ENV=production GITLAB_ROOT_PASSWORD=password


echo "--> 8.9 - Secure secrets.yml (SKIP for demo purpose)"

echo "--> 8.10 - Install Init Script"
sudo cp lib/support/init.d/gitlab /etc/init.d/gitlab
LC_ALL=en_US.UTF-8  sudo update-rc.d gitlab defaults 21


echo "--> 8.11 - Setup Logrotate"
sudo cp lib/support/logrotate/gitlab /etc/logrotate.d/gitlab

echo "--> 8.12 - Check Application Status"
sudo -u git -H bundle exec rake gitlab:env:info RAILS_ENV=production

echo "--> 8.13 - Compile Assets"
sudo -u git -H yarn install --production --pure-lockfile
sudo -u git -H bundle exec rake gitlab:assets:compile RAILS_ENV=production NODE_ENV=production

echo "--> 8.14 - Fix repo paths access"
sudo chmod -R ug+rwX,o-rwx  /home/git/repositories/
sudo chmod -R ug-s          /home/git/repositories/
sudo find /home/git/repositories/ -type d -print0 | sudo xargs -0 chmod g+s


echo "--> 8.15 - Start Your GitLab Instance"
sudo service gitlab start
# or
#sudo /etc/init.d/gitlab restart


echo "===================================================================="
echo "==> 9 - Nginx"

echo "--> 9.1 - Installation"
sudo apt-get install -y nginx

echo "--> 9.2 - Site Configuration"
sudo cp lib/support/nginx/gitlab /etc/nginx/sites-available/gitlab
sudo ln -s /etc/nginx/sites-available/gitlab /etc/nginx/sites-enabled/gitlab
sudo rm -f /etc/nginx/sites-available/default

echo "--> 9.3 - Restart"
sudo service nginx restart


echo "===================================================================="
echo "==> 10 - Double-check Application Status"

cd /home/git/gitlab
./bin/check
