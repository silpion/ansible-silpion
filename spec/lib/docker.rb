# TODO learn how to Ruby
# TODO error handling
# TODO are there docker gems?
# TODO abstract docker list commands for re-usability

require 'socket'
require 'yaml'

class Docker

  private

  @ssh_host = nil
  @ssh_port = nil
  @ssh_user = nil
  @ssh_keys = nil
  @env_name = nil
  @docker_img = nil
  @docker_tag = nil
  @docker_run = nil
  @docker_cmd = nil
  @ansible_inventory_file = nil

  def initialize
    docker_cfg = YAML.load_file('tests/docker.yml')
    @env_name = docker_cfg['env_name']
    @ssh_host = docker_cfg['ssh_host']
    @ssh_port = ssh_port?
    @ssh_user = docker_cfg['ssh_user']
    @ssh_keys = docker_cfg['ssh_keys']
    @docker_img = docker_cfg['docker_img']
    @docker_tag = docker_cfg['docker_tag']
    @docker_run = docker_cfg['docker_run'].gsub(/{{.*}}/, @ssh_port.to_s)
    @docker_cmd = docker_cfg['docker_cmd']
    if File.writable? '/tmp'
      @ansible_inventory_file = "/tmp/#{@env_name}.hosts"
    else
      @ansible_inventory_file = "#{ENV['HOME']}/#{@env_name}.hosts"
    end
  end


  # find a free port for docker to use SSH forwarding
  def ssh_port?
    port_min = 22200
    port_max = 22300

    # don't do anything if @ssh_port is already set
    if @ssh_port == nil

      # we need to verify if there is a Docker container running
      docker_ps = `docker ps`
      if docker_ps != ''
        docker_ps.each_line do |l|
          if m = /#{@env_name}/.match(l)
            docker_port = `docker port #{@env_name} 22`
            if docker_port != ''
              @ssh_port = docker_port.split(':')[1].to_i
            end
            break
          end
        end

      # there is no Docker container running for this project
      #   find a free port for SSH forwarding
      else
        while port_min < port_max do
          begin
            @ssh_port = port_min
            TCPSocket.new('localhost', @ssh_port)
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
  attr_reader :ssh_host,
    :ssh_port,
    :ssh_user,
    :ssh_keys,
    :env_name,
    :docker_img,
    :docker_tag,
    :docker_run,
    :docker_cmd,
    :ansible_inventory_file


  # provide a generated Ansible inventory hosts
  #   file for a Docker container
  def ansible_inventory_add
    unless File.exists? @ansible_inventory_file
      File.open(@ansible_inventory_file, 'w') do |c|
        c.puts "#{@env_name} ansible_connection=ssh ansible_ssh_host=#{@ssh_host} ansible_ssh_user=#{@ssh_user} ansible_ssh_port=#{@ssh_port} ansible_ssh_private_key_file=#{@ssh_keys}"
      end
    end
  end

  # remove an existing generated Ansible inventory
  #   hosts file for a Docker container
  def ansible_inventory_del
    if File.exists? @ansible_inventory_file
      File.unlink @ansible_inventory_file
    end
  end


  # pull an image from Docker index.docker.io
  def docker_pull
    need_pull = true
    docker_images = `docker images`
    if docker_images != ''
      docker_images.each_line do |l|
        if m = /^#{@docker_img}/.match(l)
          need_pull = false
          break
        end
      end
    end
    if need_pull
      `docker pull #{@docker_img}:#{@docker_tag}`
    end
  end

  # run a fresh container
  def docker_run
    need_run = true
    docker_ps = `docker ps --all`
    if docker_ps != ''
      docker_ps.each_line do |l|
        if m = /#{@env_name}/.match(l)
          need_run = false
          break
        end
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
    docker_ps = `docker ps`
    if docker_ps != ''
      docker_ps.each_line do |l|
        if m = /#{@env_name}/.match(l)
          need_start = false
          break
        end
      end
    end
    if need_start
      `docker start #{@env_name}`
    end
  end

  # stop a running container
  def docker_stop
    need_stop = false
    docker_ps = `docker ps`
    if docker_ps != ''
      docker_ps.each_line do |l|
        if m = /#{@env_name}/.match(l)
          need_stop = true
          break
        end
      end
    end
    if need_stop
      `docker stop #{@env_name}`
    end
  end

  # remove an existing container
  def docker_rm
    need_rm = false
    docker_ps = `docker ps --all`
    if docker_ps != ''
      docker_ps.each_line do |l|
        if m = /#{@env_name}/.match(l)
          need_rm = true
          break
        end
      end
    end
    if need_rm
      `docker rm --force #{@env_name}`
    end
  end

end
