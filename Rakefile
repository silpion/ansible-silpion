# TODO load docker/vagrant depending on the testing backend in use

require 'rake'
require 'rspec/core/rake_task'

# we use data from the docker configuration in rake configuration
require './spec/lib/docker'
c = Docker.new
c.ansible_inventory_add


desc "Run integration tests with serverspec"
RSpec::Core::RakeTask.new(:spec) do |t|
  t.pattern = 'spec/*/*_spec.rb'
end


desc "Test ansible playbook syntax"
task :lint do
  sh %{ansible-playbook --inventory-file tests/hosts --syntax-check tests/playbook.yml}
end
task :default => :lint


desc "Clean test environment"
task :clean do
  c.ansible_inventory_del
end


# Docker
desc "docker pull"
task :docker_pull do
  sh %{docker images|grep -q #{c.docker_img}||docker pull #{c.docker_img}:#{c.docker_tag}}
end

desc "docker run"
task :docker_run => [:docker_pull] do
  sh %{docker ps|grep -q #{c.env_name}||docker run #{c.docker_run} #{c.docker_img}:#{c.docker_tag} #{c.docker_cmd}}
end

desc "docker 'provision'"
task :docker_provision => [:docker_run] do
  sh %{ansible-playbook --inventory-file #{c.ansible_inventory_file} --limit #{c.env_name} tests/playbook.yml}
end

desc "docker stop"
task :docker_stop do
  sh %{docker ps --all|grep -q #{c.env_name}; docker stop #{c.env_name}}
end

desc "docker rm --force"
task :docker_rm => [:docker_stop] do
  sh %{docker ps --all|grep -q #{c.env_name}; docker rm --force #{c.env_name}}
end


desc "Run test suite with Docker"
task :docker => [
  :lint,
  :docker_pull,
  :docker_run,
  :docker_provision,
  :spec,
  :docker_stop,
  :docker_rm,
  :clean
]



# Vagrant
desc "vagrant up --no-provision"
task :vagrant_up do
  sh %{vagrant up --no-provision}
end

desc "vagrant provision"
task :vagrant_provision do
  sh %{vagrant provision}
end

desc "vagrant halt"
task :vagrant_halt do
  sh %{vagrant halt}
end

desc "vagrant destroy --force"
task :vagrant_destroy do
  sh %{vagrant destroy --force}
end


desc "Run test suite with Vagrant"
task :vagrant => [
  :lint,
  :vagrant_up,
  :vagrant_provision,
  :spec,
  :vagrant_halt,
  :vagrant_destroy,
  :clean
]
