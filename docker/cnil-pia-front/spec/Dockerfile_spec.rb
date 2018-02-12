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

  describe file('/var/www/pia/dist') do
    it { should be_directory }
  end

  [
    'git'
  ].each do |p|
    describe package(p) do
      it { should be_installed }
    end
  end

  describe command('node -v') do
    its(:exit_status) { should eq 0 }
    its(:stdout) { should match /^v8\./ }
  end

  describe command('npm -v') do
    its(:exit_status) { should eq 0 }
    its(:stdout) { should match /^5\./ }
  end
end
