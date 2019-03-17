require 'json'

module Puppet
  module Util
    module ResourcePiping

      def self.apply_resource(input_line, face)
        output = { 'failed' => true, 'changed' => false, 'error' => true, 'exception' => nil }
        begin
          if input_line[0] == "{"
            input = JSON.load(input_line)
            ( type, name, yaml ) = [ input["type"], input["title"], input["params"] ]
          else
            ( type, name, yaml ) = input_line.split(/ /,3)
          end
          result = face.save(type, name, yaml)
          resource = result[0]
          report = result[1]
          output = {
            'resource' => report.resource_statuses[resource.ref].resource,
            'failed' => report.resource_statuses[resource.ref].failed,
            'changed' => report.resource_statuses[resource.ref].changed,
            'noop' => report.noop,
            'error' => false,
            'exception' => nil,
          }
        rescue JSON::ParserError => e
          Puppet.err "(Applying JSON #{input_line}) #{e.message}"
          output['exception'] = e.message
        rescue Puppet::Error => e
          Puppet.err "(Applying #{type.capitalize}[#{name}]) #{e.message}"
          output['exception'] = e.message
        end
        output
      end

    end
  end
end
