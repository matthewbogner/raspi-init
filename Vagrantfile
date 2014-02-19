# -*- mode: ruby -*-
# vi: set ft=ruby :


Vagrant.configure("2") do |config2|
  config2.vm.define "build-vagrant" do |config|

    config.vm.box = "Centos6_4"
    config.vm.box_url = "http://developer.nrel.gov/downloads/vagrant-boxes/CentOS-6.4-x86_64-v20130427.box"

    config.vm.hostname = "build-vagrant"
    config.vm.network :private_network, ip: "192.168.2.5"
    config.vm.provider :virtualbox do |vb|
      vb.customize ["modifyvm", :id, "--memory", "1024"]
    end

    config.vm.provision :puppet do |puppet|
      # puppet.options = "--verbose --debug"
      # puppet.facter = { "mykey" => "myval" }
      puppet.module_path = "puppet/modules"
      puppet.manifests_path = "puppet/manifests"
      puppet.manifest_file  = "buildnode.pp"
    end
  end
end
