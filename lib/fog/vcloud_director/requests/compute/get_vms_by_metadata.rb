module Fog
  module Compute
    class VcloudDirector
      class Real

        require 'fog/vcloud_director/parsers/compute/vms_by_metadata'

        def get_vms_by_metadata(key,value)
          request(
            :expects => 200,
            :method  => 'GET',
            :parser  => Fog::Parsers::Compute::VcloudDirector::VmsByMetadata.new,
            :path    => "vms/query?format=records&filter=metadata:#{key}==STRING:#{value}"
          )
        end

      end
    end
  end
end
