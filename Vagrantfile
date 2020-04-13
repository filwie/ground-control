# vi: set ft=ruby sw=2:
# frozen_string_literal: true

# variable          | default value
# ------------------|------------------------
# VAGRANT_SSH_KEY   | `~/.ssh/id_rsa`
# VAGRANT_GIT_USER  | `git config user.name`
# VAGRANT_GIT_EMAIL | `git config user.email`

box = 'opensuse/Tumbleweed.x86_64'
hostname = 'opensuse'

vm_spec = {
  cores: 2,
  memory: 4048
}

ssh_private_key = ENV['VAGRANT_SSH_KEY'] || "#{Dir.home}/.ssh/id_rsa"
ssh_public_key = "#{ssh_private_key}.pub"
ssh_user = ENV['USER']
git_user = ENV['VAGRANT_GIT_USER'] || `git config user.name`.strip
git_user = ENV['VAGRANT_GIT_EMAIL'] || `git config user.email`.strip

repo_path = {
  host: '.',
  vm: '/opt/ground-control'
}

VAGRANT_CMD = ARGV[0]

def file_contents(file_path)
  unless File.file?(file_path)
    raise IOError, "Could not read file contents. File #{file_path} not found."
  end

  File.read(file_path)
end

def configure_provider(provider, spec)
  provider.name = hostname
  provider.memory = spec[:memory]
  provider.cpus = spec[:cores]
end

Vagrant.configure('2') do |config|
  config.vm.box = box
  config.vm.hostname = hostname
  config.vm.synced_folder '.', '/vagrant', disabled: true
  config.vm.synced_folder repo_path[:host], repo_path[:vm], type: 'nfs'

  configure_provider(config.vm.provider(:virtualbox))
  configure_provider(config.vm.provider(:libvirt))

  config.vm.provision 'ansible_local' do |ansible|
    ansible.playbook = 'bootstrap.yaml'
    ansible.provisioning_path = "#{repo_path[:vm]}/ansible"
    ansible.extra_vars = {
      "ssh_user": ssh_user,
      "ssh_public_key": file_contents(ssh_public_key).strip
    }
    ansible.compatibility_mode = '2.0'
  end

  config.vm.provision 'shell' do |sh|
    sh.keep_color = true
    sh.inline = %({
      sudo -Eu "#{ssh_user}" \
        ansible-playbook -v "#{repo_path[:vm]}/ansible/setup.yaml" \
          -i "#{repo_path[:vm]}/ansible/inventory"
    })
    sh.env = {
      'ANSIBLE_CONFIG': "#{repo_path[:vm]}/ansible/ansible.cfg",
      'ANSIBLE_FORCE_COLOR': 'TRUE'
    }
  end

  if VAGRANT_CMD == 'ssh'
    config.ssh.private_key_path = ssh_private_key
    config.ssh.username = ssh_user
  end
end
