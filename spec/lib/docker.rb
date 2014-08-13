# TODO learn how to Ruby
# TODO error handling
# TODO there's the `docker-api' gem
#       queriyng docker looks fine
#       container management feels too abstract for the moment

require 'socket'
require 'yaml'

class Docker

  private
    # environment
  @env_name = nil
    # ssh
  @ssh_host = nil
  @ssh_user = nil
  @ssh_keys = nil
  @ssh_port = nil
    # docker
  @docker_img = nil
  @docker_tag = nil
  @docker_run = nil
  @docker_cmd = nil
    # ansible
  @ansible_hosts_file = nil

  def initialize
    begin
      config = YAML.load_file('tests/docker.yml')
      @env_name = config['env_name']
      @ssh_host = config['ssh_host']
      @ssh_user = config['ssh_user']
      @ssh_keys = config['ssh_keys']
      @docker_img = config['docker_img']
      @docker_tag = config['docker_tag']
      @docker_run = config['docker_run'].gsub(/{{.*}}/, @ssh_port.to_s)
      @docker_cmd = config['docker_cmd']
    rescue
      raise 'Failed to parse configuration file: tests/docker.yml'
    end

    @ssh_port = ssh_port?

    if File.writable?('/tmp')
      @ansible_hosts_file = "/tmp/#{@env_name}.hosts"
    else
      @ansible_hosts_file = "#{ENV['HOME']}/#{@env_name}.hosts"
    end
  end


  # find a free port for docker to use SSH forwarding
  def ssh_port?
    port_min = 22200
    port_max = 22300

    # don't do anything if @ssh_port is already set
    if @ssh_port == nil

      # we need to verify if there is a Docker container running
      `docker ps`.each_line do |l|
        if m = /#{@env_name}/.match(l)
          @ssh_port = `docker port #{@env_name} 22`.split(':')[1].to_i
          break
        end
      end

      # there is no Docker container running for this project
      #   find a free port for SSH forwarding
      if @ssh_port == nil
        while port_min < port_max do
          begin
            @ssh_port = port_min
            TCPSocket.new(@ssh_host, @ssh_port)
          rescue Errno::ECONNREFUSED
            break
          rescue
            @ssh_port = 0
          end
          port_min += 1
        end
      end
    end

    @ssh_port
  end


  public
  attr_reader :env_name,
    :ssh_host,
    :ssh_user,
    :ssh_port,
    :ssh_keys,
    :ansible_hosts_file


  # provide a generated Ansible hosts inventory
  def ansible_hosts_add
    unless File.exists?(@ansible_hosts_file)
      File.open(@ansible_hosts_file, 'w') do |f|
        f.puts "#{@env_name} ansible_connection=ssh ansible_ssh_host=#{@ssh_host} ansible_ssh_user=#{@ssh_user} ansible_ssh_port=#{@ssh_port} ansible_ssh_private_key_file=#{@ssh_keys}"
      end
    end
  end

  # remove an existing generated Ansible hosts
  #   hosts file for a Docker container
  def ansible_hosts_del
    if File.exists?(@ansible_hosts_file)
      File.unlink(@ansible_hosts_file)
    end
  end


  # pull an image from Docker index.docker.io
  def docker_pull
    need_pull = true
    `docker images`.each_line do |l|
      if m = /^#{@docker_img}/.match(l)
        need_pull = false
        break
      end
    end
    if need_pull
      `docker pull #{@docker_img}:#{@docker_tag}`
    end
  end

  # run a fresh container
  def docker_run
    need_run = true
    `docker ps --all`.each_line do |l|
      if m = /#{@env_name}/.match(l)
        need_run = false
        break
      end
    end
    if need_run
      `docker run #{@docker_run} #{@docker_img}:#{@docker_tag} #{@docker_cmd}`
    else
      docker_start
    end
  end

  # start an existing but running container
  def docker_start
    need_start = true
    `docker ps`.each_line do |l|
      if m = /#{@env_name}/.match(l)
        need_start = false
        break
      end
    end
    if need_start
      `docker start #{@env_name}`
    end
  end

  # stop a running container
  def docker_stop
    need_stop = false
    `docker ps`.each_line do |l|
      if m = /#{@env_name}/.match(l)
        need_stop = true
        break
      end
    end
    if need_stop
      `docker stop #{@env_name}`
    end
  end

  # remove an existing container
  def docker_rm
    need_rm = false
    `docker ps --all`.each_line do |l|
      if m = /#{@env_name}/.match(l)
        need_rm = true
        break
      end
    end
    if need_rm
      `docker rm --force #{@env_name}`
    end
  end

end
