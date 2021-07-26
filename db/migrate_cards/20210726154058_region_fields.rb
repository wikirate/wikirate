# -*- encoding : utf-8 -*-

class RegionFields < Cardio::Migration
  TYPE_MAP = { "Country" => :pointer, "Country code" => :phrase }.freeze

  def up
    add_code_cards
    standardize_country_codes
  end

  def add_code_cards
    TYPE_MAP.each do |cardname, type|
      ensure_code_card cardname
      ensure_card [cardname, :right, :default], type: type
      update_existing_cardtypes cardname, type
    end
  end

  def update_existing_cardtypes cardname, type
    Card.search left: { type: :region }, right: cardname do |field|
      field.type = type
      field.reset_patterns
      field.include_set_modules
      field.standardize_items if type == :pointer
      field.save!
    end
  end

  def standardize_country_codes
    Card.search type: "Region" do |reg|
      cc = reg.fetch :country_code
      case reg.oc_code
      when /\w{5}/
        # puts "deleting country code for #{reg.name} (#{reg.oc_code})"
        cc&.delete!
      when /^\w\w$/
        code = cc.content
        # puts "updating country code from  #{code} to #{code.upcase} (OC: #{reg.oc_code})"
        cc.update! content: code.upcase
        # puts "setting country to self: #{reg.name}"
        reg.fetch(:country)&.update! content: [reg.name].to_pointer_content
      else
        puts "no action for #{reg.name}"
      end
    end
  end
end
