require 'spec_helper.rb'
require 'puppet/util/resource_piping'

describe "Puppet::Util::ResourcePiping" do
  subject { Puppet::Util::ResourcePiping }

  let(:face) { Puppet::Face['yamlresource','0'] }

  describe ".apply_resource" do

    [ { "description" => "a plain resource",
        "input"       => "file /a {}", },
      { "description" => "a resource with parameters",
        "input"       => "notify spec { message: This is a test message }", },
      { "description" => "a resource with unknown parameters",
        "input"       => "notify spec { adjunctive: froopily }", },
      { "description" => "a resource of unknown type",
        "input"       => "starship enterprise {}", },
      { "description" => "broken YAML for parameters",
        "input"       => "file /a { this: will: not: parse }", },
      { "description" => "a garbled input line",
        "input"       => "file /a /b /x what { ensure: file }", },
    ].each do |test|
      it "returns a hash when given #{test["description"]}" do
        output = subject.apply_resource(test["input"], face)
        expect(output).to be_a Hash
      end
    end

    it "does apply the specified resource" do
      Puppet.expects(:warning)
      subject.apply_resource("notify spec { loglevel: warning }", face)
    end

    it "respects the noop parameter" do
      Puppet.expects(:warning).never
      subject.apply_resource("notify spec { loglevel: warning, noop: True }", face)
    end

  end
end
