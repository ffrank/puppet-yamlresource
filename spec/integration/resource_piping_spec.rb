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
      { "description" => "a resource of unknown type",
        "input"       => "starship enterprise {}", },
    ].each do |test|
      it "returns a hash and no error when input is #{test["description"]}" do
        output = subject.apply_resource(test["input"], face)
        expect(output).to be_a Hash
        expect(output["error"]).to be == false
        expect(output["exception"]).to be == nil
      end
    end

    [ { "description" => "a resource with unknown parameters",
        "input"       => "notify spec { adjunctive: froopily }", },
      { "description" => "broken YAML for parameters",
        "input"       => "file /a { this: will: not: parse }", },
      { "description" => "a garbled input line",
        "input"       => "file /a /b /x what { ensure: file }", },
    ].each do |test|
      it "returns a hash with an error when given #{test["description"]}" do
        output = subject.apply_resource(test["input"], face)
        expect(output).to be_a Hash
        expect(output["error"]).to be == true
        expect(output["exception"]).to_not be == nil
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

    context "when given a line of JSON input" do

      [ { "description" => "a plain resource",
          "input"       => '{"type":"file", "title": "/a", "params": "{}"}', },
        { "description" => "a resource with parameters",
          "input"       => '{"type":"notify", "title": "spec", "params": "{message: This is a test message}"}', },
        { "description" => "a resource of unknown type",
          "input"       => '{"type":"starship", "title": "enterprise", "params": "{}"}', },
      ].each do |test|
        it "returns a hash and no error when input is #{test["description"]}" do
          output = subject.apply_resource(test["input"], face)
          expect(output).to be_a Hash
          expect(output["error"]).to be == false
          expect(output["exception"]).to be == nil
        end
      end

      [ { "description" => "a resource with unknown parameters",
          "input"       => '{"type":"notify", "title": "spec", "params": "{adjunctive: froopily}"}', },
        { "description" => "broken YAML for parameters",
          "input"       => '{"type":"file", "title": "/a", "params": "{this: will: not: parse}"}', },
        { "description" => "a garbled input line",
          "input"       => '{"type":"file", "title": "/a": "/b": "/x", "what": "{ ensure: file }"}', },
      ].each do |test|
        it "returns a hash with an error when input is #{test["description"]}" do
          output = subject.apply_resource(test["input"], face)
          expect(output).to be_a Hash
          expect(output["error"]).to be == true
          expect(output["exception"]).to_not be == nil
        end
      end

    end

  end
end
