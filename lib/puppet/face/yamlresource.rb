require 'puppet/face'
require 'yaml'

Puppet::Face.define(:yamlresource, '0.1.0') do
  
  license "Apache 2"
  copyright "Felix Frank", 2016
  author "Felix Frank <felix.frank@alumni.tu-berlin.de>"
  summary "Use the Puppet RAL to interact directly with the system."

  action :find_or_save do
    default
    render_as :yaml
    summary "The default action. Behaves like `puppet resource` for almost all intents and purposes."
    when_invoked do |*args|
      type = args[0]
      name = args[1]
      if name && !name.empty?
	parameters = args[2]
        if parameters && !parameters.empty?
          Puppet::Face[@name, @version].save(type, name, parameters)
        else
          Puppet::Face[@name, @version].find(type, name)
        end
      else
        Puppet::Face[@name, @version].search(type)
      end
    end
  end

  action :find do
    summary "Find a resource by type and name, and print its YAML representation."
    render_as :yaml
    when_invoked do |type, name, options|
      if !name || name.empty?
        raise Puppet::Error, "The :find method needs a resource type and name"
      end

      Puppet::Resource.indirection.find("#{type}/#{name}")
    end
  end

  action :search do
    summary "Returns an array of all resources of the given type that can be enumerated on the system."
    render_as :yaml
    when_invoked do |type, options|
      if !type || type.empty?
        raise Puppet::Error, "The :search method needs a resource type"
      end

      Puppet::Resource.indirection.search(type, {})
    end
  end

  action :save do
    summary "Applies a resource described by title, name and hash of attribute values."
    render_as :yaml
    when_invoked do |type, name, yaml, options|
      begin
        parameters = Psych.load(yaml)
      rescue Psych::SyntaxError => e
        Puppet.err "There was an error parsing the parameter YAML document: #{e}"
        return nil
      end

      if !parameters || !parameters.is_a?(Hash)
        raise Puppet::Error, "The :save method needs resource type, name and a hash of parameters"
      end

      if !type || type.empty? || !name || name.empty?
        raise Puppet::Error, "The resource type and name must be a valid strings"
      end

      resource = Puppet::Resource.new(type, name, :parameters => parameters)
      save_result = Puppet::Resource.indirection.save(resource, "#{type}/#{name}")
      [ save_result.first ]
    end
  end
end
