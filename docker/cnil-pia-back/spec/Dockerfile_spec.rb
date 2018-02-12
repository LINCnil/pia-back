require "docker-api"
require "serverspec"

dir = Dir.pwd
image = /^.*\/docker\/[^\/]+\/([^\/]+\/[^\/]+)$/.match(dir)[1]

describe 'Dockerfile' do
  before(:all) do
    set :os, family: :debian
    set :backend, :docker
    set :docker_image, image
    set :docker_url, 'unix:///var/run/docker.sock'
    set :docker_container_create_options, {
      'Entrypoint' => [ '/bin/sh' ]
    }
  end

  describe file("/entrypoint") do
    it { should exist }
    it { should be_executable }
  end

  describe file('/var/www') do
    it { should be_directory }
  end

  [
    'git'
  ].each do |p|
    describe package(p) do
      it { should be_installed }
    end
  end
end
