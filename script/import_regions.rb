require File.expand_path "../../config/environment", __FILE__

Card::Auth.signin "Ethan McCutchen"

REGIONS = "indian_states".freeze
FILE_PATH = File.expand_path "../csv_import/regions/#{REGIONS}.csv", __FILE__

# Import Region cards
#
# NOTES:
#
#  1. csv file expected in csv_import/regions folder.  enter filename as constant above
#     (REGIONS)
#
#  2. csv file must have a header row. First header is "Region".  Each other header
#     must be the correct field name for Region cards
module RegionImporter
  class << self
    include Card::Model::SaveHelper

    def import!
      each_region do |region, fields|
        subcards = subcards fields
        ensure_card name: region, type_id: Card::RegionID, subcards: subcards
      end
    end

    def csv_rows
      csv = File.read FILE_PATH
      CSV.parse csv, headers: true
    end

    def each_region
      csv_rows.each do |row|
        hash = row.to_h
        yield hash.delete("Region"), hash
      end
    end

    def subcards fields
      fields.each_with_object({}) do |(field, value), hash|
        hash["+#{Card::Name[field]}"] = value
      end
    end
  end
end

RegionImporter.import!
