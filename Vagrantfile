# vim: set ft=ruby sw=2:
# frozen_string_literal: true

require 'json'
require 'yaml'
require 'ostruct'

def parse_config
  conf_from_file = YAML.load_file('./config.yaml').to_json
  JSON.parse(conf_from_file, object_class: OpenStruct)
end

def file_contents(file_path)
  fp = File.expand_path(file_path)
  unless File.file?(fp)
    raise IOError, "Could not read file contents. File #{fp} not found."
  end

  File.read(fp)
end

conf = parse_config
repo_path = {
  host: '.',
  vm: '/opt/ground-control'
}

Vagrant.configure('2') do |config|
  config.vm.box = conf.spec.box
  unless (box_version = conf.spec.box_version).nil?
    config.vm.box_version = box_version
  end
  config.vm.hostname = conf.spec.hostname

  config.vm.synced_folder '.', '/vagrant', disabled: true
  config.vm.synced_folder repo_path[:host], repo_path[:vm]

  config.vm.provider :virtualbox do |vbox|
    vbox.name = conf.meta.name
    vbox.memory = conf.spec.ram
    vbox.cpus = conf.spec.cores
    vbox.customize ['modifyvm', :id, '--vram', conf.spec.vram]
    vbox.customize ['modifyvm', :id, '--accelerate3d', 'on']
    vbox.customize ['modifyvm', :id, '--clipboard', 'bidirectional']
  end

  config.vm.provider :libvirt do |libvirt|
    libvirt.cpus = conf.spec.cores
    libvirt.memory = conf.spec.ram
    libvirt.video_vram = conf.spec.vram
  end

  config.vm.provision 'shell' do |sh|
    # fixes for pacman issues on windows10/virtualbox combo...
    sh.inline = %({
      return 0
      {
        echo 'Server = http://ftp.icm.edu.pl/pub/Linux/dist/archlinux/$repo/os/$arch'
        echo 'Server = https://ftp.icm.edu.pl/pub/Linux/dist/archlinux/$repo/os/$arch'
        echo 'Server = http://arch.midov.pl/arch/$repo/os/$arch'
        echo 'Server = http://arch.nixlab.pl/$repo/os/$arch'
        echo 'Server = https://arch.nixlab.pl/$repo/os/$arch'
        echo 'Server = http://mirror.onet.pl/pub/mirrors/archlinux/$repo/os/$arch'
        echo 'Server = http://piotrkosoft.net/pub/mirrors/ftp.archlinux.org/$repo/os/$arch'
        echo 'Server = http://mirror.sfinae.tech/pub/mirrors/archlinux/$repo/os/$arch'
        echo 'Server = https://mirror.sfinae.tech/pub/mirrors/archlinux/$repo/os/$arch'
        echo 'Server = http://ftp.vectranet.pl/archlinux/$repo/os/$arch'
      } | tee /etc/pacman.d/mirrorlist

      {
        echo 'nameserver 1.1.1.1'
        echo 'nameserver 8.8.8.8'
      } | tee /etc/resolv.conf


      # https://bbs.archlinux.org/viewtopic.php?id=253809&p=2

      mkdir /etc/gcrypt/
      {
        echo 'padlock-rng'
        echo 'padlock-aes'
        echo 'padlock-sha'
        echo 'padlock-mmul'
        echo 'intel-cpu'
        echo 'intel-fast-shld'
        echo 'intel-bmi2'
        echo 'intel-ssse3'
        echo 'intel-pclmul'
        echo 'intel-aesni'
        echo 'intel-rdrand'
        echo 'intel-avx'
        echo 'intel-avx2'
        echo 'intel-rdtsc'
        echo 'arm-neon'
      } | tee /etc/gcrypt/hwf.deny

      timedatectl set-timezone Europe/Warsaw
      hwclock -w

      pacman -Scc --noconfirm
      rm -R /etc/pacman.d/gnupg/
      yes | gpg --refresh-keys
      yes | pacman-key --init
      yes | pacman-key --populate
      yes | pacman-key --refresh-keys

      rm -rf /var/cache/pacman/pkg/*
      pacman -Syyu --needed --noconfirm ansible archlinux-keyring
    })
  end

  config.vm.provision 'ansible_local' do |ansible|
    ansible.playbook = 'bootstrap.yaml'
    ansible.config_file = "#{repo_path[:vm]}/ansible/ansible.cfg"
    ansible.provisioning_path = "#{repo_path[:vm]}/ansible"
    ansible.extra_vars = {
      "ssh_user": conf.provisioning.ssh_user,
      "ssh_public_key": file_contents(conf.provisioning.ssh_public_key).strip
    }
    ansible.compatibility_mode = '2.0'
  end

  config.vm.provision 'shell' do |sh|
    sh.keep_color = true
    # TODO: make paths configurable?
    sh.inline = %({
      sudo -Eu "#{conf.provisioning.ssh_user}" \
        ansible-playbook -v "#{repo_path[:vm]}/ansible/setup.yaml" \
          -i "#{repo_path[:vm]}/ansible/inventory.yaml"
    })
    # TODO: placing config in shared folder may cause it to be ignored
    #       if the directory has too wide permissions
    sh.env = {
      'ANSIBLE_CONFIG': "#{repo_path[:vm]}/ansible/ansible.cfg",
      'ANSIBLE_FORCE_COLOR': 'TRUE',
      'ANSIBLE_LOCAL_TEMP': '/tmp/ansible_local'
    }
  end

  if ARGV[0] == 'ssh'
    config.ssh.private_key_path = File.expand_path(conf.provisioning.ssh_private_key)
    config.ssh.username = conf.provisioning.ssh_user
  end
end
