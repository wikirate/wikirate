# -*- encoding : utf-8 -*-

class JurisdictionToRegion < Cardio::Migration
  def up
    ensure_card name: "Region", type_id: CardtypeID, codename: "region"
    ensure_card name: ["Region", :type, :structure], type_id: NestListID,
                content: "{{+Continent|labeled|name}}\n" \
                         "{{+OpenCorporates Jurisdiction key|labeled|name}}\n" \
                         "{{+ILO Region|labeled|name}}\n" \
                         "{{+Country|labeled|name}}"
    Card::Cache.reset_all

    Card.search(type_id: Card::JurisdictionID) do |card|
      ensure_card name: "#{card.name}+OpenCorporates Jurisdiction key", content: card.codename,
                  type_id: Card::JurisdictionID
      card.update codename: nil, type_id: Card::RegionID
    end

    country_map.each do |id, country|
      Card.fetch(id.to_i).update subcards: { "+Country" => country }
    end
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
end
