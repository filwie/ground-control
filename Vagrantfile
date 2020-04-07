# vi: set ft=ruby sw=2:
# frozen_string_literal: true

box = 'opensuse/openSUSE-Tumbleweed-Vagrant.x86_64'
hostname = 'opensuse'

vm_spec = {
  cores: 2,
  mem: 4048,
}

ssh_private_key = ENV['VAGRANT_SSH_KEY'] || "#{Dir.home}/.ssh/id_rsa"
ssh_public_key = "#{ssh_private_key}.pub"

def get_file_contents(file_path)
  unless File.file?(file_path)
    raise IOError, "Could not read file contents. File #{file_path} not found."
  end
  File.read(file_path)
end

# repo_root_host = `git rev-parse --show-toplevel`.tr('\n', '/')
# repo_root_vm = '/opt/ground-control'

# provision_playbook = "provision.yaml"
# provision_playbook_skip_tags = ["kvm"]
# provision_playbook_extra_vars= {}

# if ENV.key?("GITHUB_USERNAME") && ENV.key?("GITHUB_TOKEN")
#     provision_playbook_extra_vars = {
#         github_username: ENV["GITHUB_USERNAME"],
#         github_api_token: ENV["GITHUB_TOKEN"],
#     }
# else
#     provision_playbook_skip_tags.push("github")
# end

Vagrant.configure('2') do |config|
  config.vm.box = box
  config.vm.hostname = hostname
  config.vm.synced_folder repo_root_host, repo_root_vm

  config.vm.provider :virtualbox do |v|
    v.memory = vm_spec[:memory]
    v.cpus = vm_spec.cores
  end

  config.vm.provider :libvirt do |v|
    v.memory = 2048
    v.cpus = 2
  end

  config.ssh.private_key_path = ssh_private_key

  # config.vm.provision 'ansible_local' do |ansible|
  #   ansible.playbook = provision_playbook
  #   ansible.provisioning_path = repo_root_vm + '/ansible'
  #   ansible.extra_vars = provision_playbook_extra_vars
  #   ansible.skip_tags = provision_playbook_skip_tags
  # end

  # config.trigger.before :destroy do |trigger|
  #   trigger.info = "Running teardown playbook"
  #   trigger.run_remote = {
  #     inline: "sudo -u %s ansible-playbook %s -i %s/inventory $*" % [ANSIBLE_USER, ANSIBLE_PLAYBOOK_TEARDOWN, ansible_directory],
  #     args: ANSIBLE_ARGS
  #   }
  # end
end