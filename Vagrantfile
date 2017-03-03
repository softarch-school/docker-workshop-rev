Vagrant.configure(2) do |config|
  config.vm.box = "williamyeh/ubuntu-trusty64-docker"

  #config.vm.provider "virtualbox" do |vb|
  #  vb.customize ["modifyvm", :id, "--memory", "1024"]
  #end

  config.vm.provision "shell", inline: <<-SHELL
    cd /vagrant

    echo "===> Native Redis server..."
    export LC_ALL=en_US.UTF-8
    export DEBIAN_FRONTEND=noninteractive
    sudo apt-get install -y software-properties-common
    sudo add-apt-repository -y ppa:chris-lea/redis-server
    sudo apt-get update
    sudo apt-get install -y 'redis-server=3:3.2.8*'
    sudo service redis-server stop
  SHELL

end
