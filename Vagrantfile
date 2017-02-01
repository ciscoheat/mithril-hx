# -*- mode: ruby -*-
# vi: set ft=ruby :

# === NOTE: All Viagrant additions starts with "===".

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  # For a complete config reference, please see the online documentation at vagrantup.com.

  # === This box is used exclusively for Viagrant provision scripts.
  # === Changing it may lead to unforeseen side-effects.
  config.vm.box = "hashicorp/precise64"

  # === SECURITY NOTICE:
  # === If you're worrying about security and prefer not to use the shared
  # === "insecure_private_key" in the VAGRANT_HOME directory instead of Vagrant
  # === auto-generating a new one in the local .vagrant dir, comment this out:
  config.ssh.insert_key = false

  # Disable automatic box update checking. If you disable this, then
  # boxes will only be checked for updates when the user runs
  # `vagrant box outdated`. This is not recommended.
  # config.vm.box_check_update = false

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine. 
  
  # config.vm.network "forwarded_port", guest: 80, host: 0

  # Create a private network, which allows host-only access to the machine
  # using a specific IP.
  # config.vm.network "private_network", ip: "192.168.33.10"

  # Create a public network, which generally matched to bridged network.
  # Bridged networks make the machine appear as another physical device on
  # your network.
  # config.vm.network "public_network"

  # If true, then any SSH connections made will enable agent forwarding.
  # Default value: false
  # config.ssh.forward_agent = true

  # Share an additional folder to the guest VM. The first argument is
  # the path on the host to the actual folder. The second argument is
  # the path on the guest to mount the folder. And the optional third
  # argument is a set of non-required options.  
  # config.vm.synced_folder "./www", "/var/www"

  config.vm.provider :virtualbox do |v|
    v.name = "mithril"
    v.customize ["modifyvm", :id, "--memory", 512]
    v.customize ["modifyvm", :id, "--natdnshostresolver1", "on"] # Use NAT DNS host resolver
    # === Allow Node.js to create symlinks for packages:
    v.customize ["setextradata", :id, "VBoxInternal2/SharedFoldersEnableSymlinksCreate/vagrant", "1"]
    # === Starting vagrant as administrator may be required as well.
    # === If it still doesn't work, execute on windows in an admin prompt: 
    # === fsutil behavior set SymlinkEvaluation L2L:1 R2R:1 L2R:1 R2L:1
    # === See http://xiankai.wordpress.com/2013/12/26/symlinks-with-vagrant-virtualbox/ for more info
  end

  # Provider-specific configuration so you can fine-tune various
  # backing providers for Vagrant. These expose provider-specific options.
  # Example for VirtualBox:
  #
  # config.vm.provider "virtualbox" do |vb|
  #   # Don't boot with headless mode
  #   vb.gui = true
  #
  #   # Use VBoxManage to customize the VM. For example to change memory:
  #   vb.customize ["modifyvm", :id, "--memory", "1024"]
  # end
  #
  # View the documentation for the provider you're using for more
  # information on available options.

  config.vm.provision :shell, path: "provision.sh"
end
