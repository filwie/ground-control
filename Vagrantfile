# vi: set ft=ruby sw=2:
# frozen_string_literal: true

box = 'opensuse/Tumbleweed.x86_64'
hostname = 'opensuse'

vm_spec = {
  cores: 2,
  memory: 4048
}

ssh_private_key = ENV['VAGRANT_SSH_KEY'] || "#{Dir.home}/.ssh/id_rsa"
ssh_public_key = "#{ssh_private_key}.pub"
ssh_user = ENV['USER']

repo_path = {
  host: `git rev-parse --show-toplevel`.strip,
  vm: '/opt/ground-control'
}

VAGRANT_CMD = ARGV[0]

def get_file_contents(file_path)
  unless File.file?(file_path)
    raise IOError, "Could not read file contents. File #{file_path} not found."
  end

  File.read(file_path)
end

Vagrant.configure('2') do |config|
  config.vm.box = box
  config.vm.hostname = hostname
  config.vm.synced_folder repo_path[:host], repo_path[:vm]

  config.vm.provider :virtualbox do |v|
    v.name = hostname
    v.memory = vm_spec[:memory]
    v.cpus = vm_spec[:cores]
  end

  config.vm.provider :libvirt do |v|
    v.default_prefix = hostname
    v.memory = vm_spec[:memory]
    v.cpus = vm_spec[:cores]
  end

  if VAGRANT_CMD == 'ssh'
    config.ssh.private_key_path = ssh_private_key
    config.ssh.username = ssh_user
  end

  config.vm.provision 'ansible_local' do |ansible|
    ansible.playbook = 'bootstrap.yaml'
    ansible.provisioning_path = "#{repo_path[:vm]}/ansible"
    ansible.extra_vars = {
      "ssh_user": ssh_user,
      "ssh_public_key": get_file_contents(ssh_public_key).strip
    }
    ansible.compatibility_mode = '2.0'
  end

  config.vm.provision 'shell' do |sh|
    sh.keep_color = true
    sh.inline = %({
      sudo -Eu "#{ssh_user}" \
        ansible-playbook "#{repo_path[:vm]}/ansible/setup.yaml" \
          -i "#{repo_path[:vm]}/ansible/inventory"
    })
    sh.env = {
      'ANSIBLE_CONFIG': "#{repo_path[:vm]}/ansible/ansible.cfg",
      'ANSIBLE_FORCE_COLOR': 'TRUE'
    }
  end

  # config.trigger.before :destroy do |trigger|
  #   trigger.info = "Running teardown playbook"
  #   trigger.run_remote = {
  #     inline: "sudo -u %s ansible-playbook %s -i %s/inventory $*" % [ANSIBLE_USER, ANSIBLE_PLAYBOOK_TEARDOWN, ansible_directory],
  #     args: ANSIBLE_ARGS
  #   }
  # end
end
