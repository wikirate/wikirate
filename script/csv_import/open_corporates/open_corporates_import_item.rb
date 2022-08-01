# SPDX-FileCopyrightText: 2022 WikiRate info@wikirate.org
#
# SPDX-License-Identifier: GPL-3.0-or-later

require_relative "../../../mod/csv_import/lib/import_item.rb"
require_relative "../../../mod/csv_import/lib/csv_file.rb"

# import OC mappings
class OpenCorporatesImportItem < ImportItem
  @columns =
    [:oc_jurisdiction_code, :oc_company_number, :wikirate_number, :company_name,
     :country,  :inc_jurisdiction_code,
     :headquarters_address]

  @required = [:oc_jurisdiction_code, :oc_company_number, :wikirate_number]

  def normalize_oc_jurisdiction_code value
    "oc_#{value}".to_sym
  end

  def normalize_inc_jurisdiction_code value
    return if value.blank? || value == "null"
    "oc_#{value}".to_sym
  end

  def validate_wikirate_number value
    value.number? && (@company = Card[value.to_i]) &&
      @company.type_id == Card::WikirateCompanyID
  end

  def validate_oc_jurisdiction_code value
    validate_jurisdiction value
  end

  def validate_inc_jurisdiction_code value
    return true if value.blank?
    validate_jurisdiction value
  end

  def validate_jurisdiction value
    Card.search(content: value, right_id: Card::OcJurisdictionKeyID).present?
  end

  def import
    ensure_card [@company, :open_corporates],
                content: oc_company_number,
                type: :phrase
    ensure_card [@company, :headquarters],
                content: Card[oc_jurisdiction_code].name,
                type: :pointer
    return unless inc_jurisdiction_code.present?
    ensure_card [@company, :incorporation],
                content: Card[inc_jurisdiction_code].name,
                type: :pointer
  end
end
