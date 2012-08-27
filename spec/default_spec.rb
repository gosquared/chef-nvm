require 'chefspec'

describe 'chef-nvm::default' do
  context "with just one version of node" do
    let! (:chef_run) do
      ChefSpec::ChefRunner.new do |node|
        node['nvm'] = {}

        node['nvm']['user'] = 'action'
        node['nvm']['node_versions'] = ['v0.6.18']
      end
    end

    before do
      chef_run.converge 'chef-nvm::default'
    end

    it "should install the package git-core" do
      chef_run.should install_package 'git-core'
    end

    it "should download and install nvm" do
      chef_run.should execute_command <<-EOF
if [ ! -d /home/action/.nvm ]
  then
    git clone git://github.com/creationix/nvm.git /home/action/.nvm
fi

grep nvm.sh /home/action/.bashrc

if [ $? -eq 1 ]
  then
    echo -e '\n\n. ~/.nvm/nvm.sh' >> /home/action/.bashrc
    . ~/.nvm/nvm.sh
fi
      EOF
    end

    it "should install the given node version" do
      chef_run.should execute_command "nvm install v0.6.18"
    end

    it "should install the first element in the array of node versions as the default" do
      chef_run.should execute_command "nvm alias default v0.6.18"
    end
  end


  context "with more than one version of node (and no default set)" do
    let! (:chef_run) do
      ChefSpec::ChefRunner.new do |node|
        node['nvm'] = {}

        node['nvm']['user'] = 'action'
        node['nvm']['node_versions'] = ['v0.6.18', 'v0.8.0']
      end
    end

    before do
      chef_run.converge 'chef-nvm::default'
    end

    it "should install the package git-core" do
      chef_run.should install_package 'git-core'
    end

    it "should download and install nvm" do
      chef_run.should execute_command <<-EOF
if [ ! -d /home/action/.nvm ]
  then
    git clone git://github.com/creationix/nvm.git /home/action/.nvm
fi

grep nvm.sh /home/action/.bashrc

if [ $? -eq 1 ]
  then
    echo -e '\n\n. ~/.nvm/nvm.sh' >> /home/action/.bashrc
    . ~/.nvm/nvm.sh
fi
      EOF
    end

    it "should install all the node versions" do
      chef_run.should execute_command "nvm install v0.6.18\nnvm install v0.8.0"
    end

    it "should install the first element in the array of node versions as the default" do
      chef_run.should execute_command "nvm alias default v0.6.18"
    end
  end

  context "with more than one version of node (and a default set)" do
    let! (:chef_run) do
      ChefSpec::ChefRunner.new do |node|
        node['nvm'] = {}

        node['nvm']['user'] = 'action'
        node['nvm']['node_versions'] = ['v0.6.18', 'v0.8.0']
        node['nvm']['default_node_version'] = 'v0.8.0'
      end
    end

    before do
      chef_run.converge 'chef-nvm::default'
    end

    it "should install the package git-core" do
      chef_run.should install_package 'git-core'
    end

    it "should download and install nvm" do
      chef_run.should execute_command <<-EOF
if [ ! -d /home/action/.nvm ]
  then
    git clone git://github.com/creationix/nvm.git /home/action/.nvm
fi

grep nvm.sh /home/action/.bashrc

if [ $? -eq 1 ]
  then
    echo -e '\n\n. ~/.nvm/nvm.sh' >> /home/action/.bashrc
    . ~/.nvm/nvm.sh
fi
      EOF
    end

    it "should install all the node versions" do
      chef_run.should execute_command "nvm install v0.6.18\nnvm install v0.8.0"
    end

    it "should install the first element in the array of node versions as the default" do
      chef_run.should execute_command "nvm alias default v0.8.0"
    end
  end
end
