# SPDX-FileCopyrightText: 2022 WikiRate info@wikirate.org
#
# SPDX-License-Identifier: GPL-3.0-or-later

require_relative "open_corporates_import_item"

# CSV import without incorporation place
class OpenCorporatesImportItemOnlyHeadquarters < OpenCorporatesImportItem
  @columns = [:oc_jurisdiction_code, :oc_company_number, :wikirate_number, :company_name]
  @required = [:oc_jurisdiction_code, :oc_company_number, :wikirate_number]

  def inc_jurisdiction_code
    nil
  end
end
