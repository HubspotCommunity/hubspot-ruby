module Hubspot
  class Utils
    class << self
      # Parses the hubspot properties format into a key-value hash
      def properties_to_hash(props)
        newprops = HashWithIndifferentAccess.new
        props.each { |k, v| newprops[k] = v["value"] }
        newprops
      end

      # Converts an array of property objects into a hash with the property name
      # as the key
      def properties_array_to_hash(props)
        props.inject({}) { |h, x| h[x["name"]] = x; h }
      end

      # Turns a hash into the hubspot properties format
      def hash_to_properties(hash, opts = {})
        key_name = opts[:key_name] || "property"
        hash.map { |k, v| { key_name => k.to_s, "value" => v } }
      end

      def dump_properties(klass, hapikey=ENV['HUBSPOT_API_KEY'], filter={})
        Hubspot::Deprecator.build.deprecation_warning("Hubspot::Utils.dump_properties")

        with_hapikey(hapikey) do
          { 'groups'     => klass.groups({}, filter),
            'properties' => klass.all({}, filter).select { |p| !p['hubspotDefined'] }
          }
        end
      end

      def restore_properties(klass, hapikey=ENV['HUPSPOT_API_KEY'], properties={}, dry_run=false)
        Hubspot::Deprecator.build.deprecation_warning("Hubspot::Utils.restore_properties")

        existing_properties                       = dump_properties(klass, hapikey)
        skip, new_groups, new_props, update_props = compare_property_lists(klass, properties, existing_properties)
        puts '', 'Dry Run - Changes will not be applied' if dry_run
        puts '','Skipping'
        skip.each { |h| puts "#{h[:reason]} - #{h[:prop]['groupName']}:#{h[:prop]['name']}" }
        with_hapikey(hapikey) do
          create_groups(klass, new_groups, dry_run)
          create_properties(klass, new_props, dry_run)
          update_properties(klass, update_props, dry_run)
        end
      end

      def create_groups(klass, groups, dry_run=false)
        puts '','Creating new groups'
        groups.each do |g|
          if dry_run || klass.create_group!(g)
            puts "Created: #{g['name']}"
          else
            puts "Failed: #{g['name']}"
          end
        end
      end

      def create_properties(klass, props, dry_run=false)
        puts '','Creating new properties'
        props.each do |p|
          if dry_run || klass.create!(p)
            puts "Created: #{p['groupName']}:#{p['name']}"
          else
            puts "Failed: #{p['groupName']}:#{p['name']}"
          end
        end
      end

      def update_properties(klass, props, dry_run=false)
        puts '','Updating existing properties'
        props.each do |p|
          if dry_run || klass.update!(p['name'], p)
            puts "Updated: #{p['groupName']}:#{p['name']}"
          else
            puts "Failed: #{p['groupName']}:#{p['name']}"
          end
        end
      end

      def compare_property_lists(klass, source, target)
        skip         = [] # Array of skipped properties and the reason
        new_groups   = Set.new # Array of groups to create
        new_props    = [] # Array of properties to add
        update_props = [] # Array of properties to update
        src_groups   = source['groups']
        dst_groups   = target['groups']
        src_props    = source['properties']
        dst_props    = target['properties']

        src_props.each do |src|
          group = find_by_name(src['groupName'], src_groups)
          if src['createdUserId'].blank? && src['updatedUserId'].blank? then
            skip << { prop: src, reason: 'Not user created' }
          else
            dst = find_by_name(src['name'], dst_props)
            if dst
              if dst['readOnlyDefinition']
                skip << { prop: src, reason: 'Definition is read-only' }
              elsif klass.same?(src, dst)
                skip << { prop: src, reason: 'No change' }
              else
                new_groups << group unless group.blank? || find_by_name(group['name'], dst_groups)
                update_props << src
              end
            else
              new_groups << group unless group.blank? || find_by_name(group['name'], dst_groups)
              new_props << src
            end
          end
        end
        [skip, new_groups.to_a, new_props, update_props]
      end

      def with_hapikey(hapikey)
        Hubspot.configure(hapikey: hapikey)
        yield if block_given?
      end

      private

      def find_by_name(name, set)
        set.detect { |item| item['name'] == name }
      end
    end
  end
end
