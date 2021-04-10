# -*- encoding : utf-8 -*-

class JurisdictionToRegion < Cardio::Migration
  def up
    ensure_card name: "Country code", codename:    "country_code"
    ensure_card name: "OpenCorporates Jurisdiction key", codename: "oc_jurisdiction_key"
    ensure_card name: "ILO Region", codename: "ilo_region"
    ensure_card name: "Region", type_id: Card::CardtypeID, codename: "region"
    ensure_card name: ["Region", :type, :structure], type_id: Card::NestListID,
                content: "{{+Continent|labeled|name}}\n" \
                                   "{{+OpenCorporates Jurisdiction key|labeled|name}}\n" \
                                   "{{+ILO Region|labeled|name}}\n" \
                                   "{{+Country|labeled|name}}\n" \
                                   "{{+Country code|labeled|name}}"
    Card::Cache.reset_all

    move_oc_country_codes

    country_map.each do |id, country|
      Card.fetch(id.to_i).update subcards: { "+Country" => country }
    end

    import_ilo_regions
  end

  def country_map
    country_groups = Card::Set::Self::Jurisdiction::CountryGroups.new
    id_to_country = []
    country_groups.each do |country|
      next unless country[:children]
      country[:children].each do |region|
        id_to_country << [region[:id], country[:text]]
      end
    end
    id_to_country
  end

  def move_oc_country_codes
    Card.search(type_id: Card::JurisdictionID) do |card|
      jur_code = card.codename.to_s.sub(/^oc_/, "")
      ensure_card name: [card.name, :oc_jurisdiction_key], content: jur_code
      card.update codename: nil, type_id: Card::RegionID
      if jur_code.size >= 2
        ensure_card name: [card.name, :country_code], content: jur_code[0..1]
      end
    end
  end

  def import_ilo_regions
    each_region do |region, country, ilo|
      ensure_card name: region, type_id: Card::RegionID,
                  subcards: { "+Country" => country, "+ILO Region" => ilo }
    end
  end

  def each_region
    path = File.expand_path "../csv/headquarters_country_mapping.csv", __FILE__
    csv = File.read path
    rows = CSV.parse csv, headers: true
    rows.each { |row| yield row }
  end
end
