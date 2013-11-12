module Fog
  module DNS
    class AWS
      class Real

        require 'fog/aws/parsers/dns/list_resource_record_sets'

        # list your resource record sets
        #
        # ==== Parameters
        # * zone_id<~String> -
        # * options<~Hash>
        #   * type<~String> -
        #   * name<~String> -
        #   * identifier<~String> -
        #   * max_items<~Integer> -
        #
        # ==== Returns
        # * response<~Excon::Response>:
        #   * body<~Hash>:
        #     * 'ResourceRecordSet'<~Array>:
        #       * 'Name'<~String> -
        #       * 'Type'<~String> -
        #       * 'TTL'<~Integer> -
        #       * 'AliasTarget'<~Hash> -
        #         * 'HostedZoneId'<~String> -
        #         * 'DNSName'<~String> -
        #       * 'ResourceRecords'<~Array>
        #         * 'Value'<~String> -
        #     * 'IsTruncated'<~String> -
        #     * 'MaxItems'<~String> -
        #     * 'NextRecordName'<~String>
        #     * 'NextRecordType'<~String>
        #     * 'NextRecordIdentifier'<~String>
        #   * status<~Integer> - 201 when successful
        def list_resource_record_sets(zone_id, options = {})

          # AWS methods return zone_ids that looks like '/hostedzone/id'.  Let the caller either use
          # that form or just the actual id (which is what this request needs)
          zone_id = zone_id.sub('/hostedzone/', '')

          parameters = {}
          options.each do |option, value|
            case option
            when :type, :name, :identifier
              parameters[option] = "#{value}"
            when :max_items
              parameters['maxitems'] = "#{value}"
            end
          end

          request({
            :query   => parameters,
            :parser  => Fog::Parsers::DNS::AWS::ListResourceRecordSets.new,
            :expects => 200,
            :method  => 'GET',
            :path    => "hostedzone/#{zone_id}/rrset"
          })

        end

      end

      class Mock

        def list_resource_record_sets(zone_id, options = {})
          maxitems = [options[:max_items]||100,100].min

          zone = self.data[:zones][zone_id]
          if options[:type]
            records = zone[:records][options[:type]].values
          else
            records = zone[:records].values.first.values
          end

          if options[:name]
            name = options[:name].gsub(zone[:name],"")
            records = records.select{|r| r[:name].gsub(zone[:name],"") >= name }
          end

          next_records = records[maxitems]
          records      = records[0, maxitems]
          truncated    = !next_records.nil?

          response = Excon::Response.new
          response.status = 200
          response.body = {
            'ResourceRecordSets' => records.map do |r|
              {
                'ResourceRecords' => r[:resource_records],
                'Name' => r[:name],
                'Type' => r[:type],
                'TTL' => r[:ttl]
              }
            end,
            'MaxItems' => maxitems.to_s,
            'IsTruncated' => truncated.to_s
          }

          if truncated
            response.body['NextMarker'] = next_records[:id]
          end

          response
        end

      end
    end
  end
end
