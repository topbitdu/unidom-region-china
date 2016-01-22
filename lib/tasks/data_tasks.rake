desc 'unidom:region:china:import Rake Task imports China regions from the given CSV file.'

namespace :unidom do
  namespace :region do
    namespace :china do

      # bundle exec rake unidom:region:china:import
      #   file=/data.csv
      #   from_date=2020-01-01
      #   schema_id=
      #   schema_type=
      task import: :environment do

        include ::Unidom::Common::DataHelper

        file_name   = ENV['file']
        schema_id   = ENV['schema_id']||::Unidom::Common::NULL_UUID
        schema_type = ENV['schema_type']||''
        opened_at   = parse_time ENV['from_date']

        updated_count = 0
        created_count = 0

        region_entities = ::Unidom::Region::China::Region.schema_id_is(schema_id).schema_type_is(schema_type).select('id, name, virtual, numeric_code, alphabetic_code, schema_id, schema_type, opened_at, closed_at, defunct, updated_at').to_a

        each_csv_row file_name do |region|

          numeric_code    = region['numeric_code']
          alphabetic_code = region['alphabetic_code']

          attributes = { name: region['name'], virtual: region['virtual'], schema_id: schema_id, schema_type: schema_type, opened_at: opened_at }
          attributes[:alphabetic_code] = alphabetic_code if alphabetic_code.present?

          if region_entities.present?
            found_region_entities = region_entities.select { |region_entity| region_entity.numeric_code==numeric_code }
            if found_region_entities.present?
              found_region_entities.each do |found_region_entity|
                found_region_entity.assign_attributes attributes
                if found_region_entity.changed?
                  found_region_entity.save!
                  updated_count += 1
                end
              end
            else
              attributes[:numeric_code] = numeric_code
              ::Unidom::Region::China::Region.create! attributes
              created_count += 1
            end
          else
            attributes[:numeric_code] = numeric_code
            ::Unidom::Region::China::Region.create! attributes
            created_count += 1
          end

        end

        puts "#{created_count} China Regions were created. #{updated_count} China Regions were updated per CSV."
        puts "#{created_count+updated_count} China Regions were handled totally."

      end

    end
  end
end
