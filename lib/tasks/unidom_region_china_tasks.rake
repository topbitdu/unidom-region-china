desc 'unidom:region:china:import Rake Task imports China regions from the given CSV file.'

namespace :unidom do
  namespace :region do
    namespace :china do

      # bundle exec rake unidom:region:china:import
      #   file=/data.csv
      #   from_date=2020-01-01
      #   owner_id=
      #   owner_type=
      task import: :environment do

        include ::Unidom::Common::DataHelper

        file_name  = ENV['file']
        owner_id   = ENV['owner_id']||'00000000-0000-0000-0000-000000000000'
        owner_type = ENV['owner_type']||''

        updated_count = 0
        created_count = 0

        each_csv_row file_name do |region|

          numeric_code    = region['numeric_code']
          alphabetic_code = region['alphabetic_code']

          attributes = { name: region['name'], virtual: region['virtual'], owner_id: owner_id, owner_type: owner_type }
          attributes[:alphabetic_code] = alphabetic_code if alphabetic_code.present?

          county = ::Unidom::Region::China::Region.numeric_coded_as(numeric_code).first

          if county.present?
            county.update_attributes attributes
            updated_count += 1
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
