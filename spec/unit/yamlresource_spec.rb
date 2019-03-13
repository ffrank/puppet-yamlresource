require 'spec_helper.rb'

describe "puppet yamlresource" do

  subject { Puppet::Face["yamlresource", "0"] }

  let(:input) { { type: "file", name: "/tmp/specfile", yaml: "{ ensure: file }" } }
  let(:broken) { "{ mode: '0744', file: ensure: present }" }
  let(:input_line) { "file /tmp/specfile { ensure: file }" }

  describe :save do
    it "uses Psych to parse the yaml input" do
      Psych.expects(:load).with(input[:yaml]).returns({ 'ensure' => 'file' })
      subject.save(input[:type], input[:name], input[:yaml])
    end

    it "wraps syntax errors as Puppet::Errors" do
      expect { subject.save(input[:type], input[:name], broken) }.to raise_error(Puppet::Error)
    end

    it "raises an error if there is no type" do
      expect { subject.save(nil, input[:name], input[:yaml]) }.to raise_error(Puppet::Error)
    end
    it "raises an error if there is no name" do
      expect { subject.save(input[:type], "null", input[:yaml]) }.to raise_error(Puppet::Error)
    end
    it "raises an error if there is no params" do
      expect { subject.save(input[:type], input[:name], "null") }.to raise_error(Puppet::Error)
    end

    it "raises an error if the parameters are not in hash form" do
      expect { subject.save(input[:type], input[:name], "[]") }.to raise_error(Puppet::Error)
    end

    it "hands off valid input to Puppet::Resource.indirection" do
      Puppet::Resource.indirection.expects(:save)
      subject.save(input[:type], input[:name], input[:yaml])
    end
  end

  describe :find do
    it "raises an error no resource type was passed" do
      expect { subject.find(nil, nil) }.to raise_error(Puppet::Error)
    end
    it "raises an error no resource name was passed" do
      expect { subject.find(input[:type], nil) }.to raise_error(Puppet::Error)
    end

    it "hands off valid input to Puppet::Resource.indirection" do
      Puppet::Resource.indirection.expects(:find)
      subject.find(input[:type], input[:name])
    end
  end

  describe :search do
    it "raises an error no resource type was passed" do
      expect { subject.search(nil) }.to raise_error(Puppet::Error)
    end

    it "hands off valid input to Puppet::Resource.indirection" do
      Puppet::Resource.indirection.expects(:search)
      subject.search(input[:type])
    end
  end

  describe :find_or_save do
    it "calls :save when invoked with three parameters" do
      subject.expects(:save).returns(['resource', 'report'])
      subject.find_or_save(input[:type], input[:name], input[:yaml])
    end

    it "calls :find when invoked with two parameters" do
      subject.expects(:find)
      subject.find_or_save(input[:type], input[:name])
    end

    it "calls :search when invoked with one parameter" do
      subject.expects(:search)
      subject.find_or_save(input[:type])
    end
  end

  describe :receive do

    before(:each) do
      STDIN.expects(:each_line).yields(input_line)
      STDOUT.expects(:puts)
    end

    it "suppresses informational messages from Puppet" do
      Puppet::Util::ResourcePiping.stubs(:apply_resource)
      Puppet.expects(:[]=).with(:log_level, :warning)
      subject.receive
    end

    it "relies on Puppet::Util::ResourcePiping.apply_resource" do
      Puppet::Util::ResourcePiping.expects(:apply_resource)
      subject.receive
    end
  end
end
