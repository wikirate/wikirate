#!/usr/bin/env ruby

require File.expand_path "../../config/environment", __FILE__

Card::Auth.signin "Ethan McCutchen"

REGIONS = "indian_states"
FILE_PATH = File.expand_path "../csv_import/regions/#{REGIONS}.csv", __FILE__
COLUMNS = [:region, :oc_jurisdiction_key, "ILO Region", "Country", :country_code]

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
      CSV.parse csv
    end

    def each_region
      csv_rows.each do |row|
        hash = row_to_hash row
        yield hash.delete(:region), hash
      end
    end

    def row_to_hash row
      row.each.with_index.with_object({}) do |(item, index), hash|
        hash[COLUMNS[index]] = item
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