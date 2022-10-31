# SPDX-FileCopyrightText: 2014 2014 Laureen van Breen, <laureen@wikirate.org> et al.
#
# SPDX-License-Identifier: GPL-3.0-or-later

require_relative "../../../config/environment"
require_relative "logo_import_item"
require_relative "../csv_file"

csv_path = File.expand_path "../data/company_logos.csv", __FILE__
Card::ImportCsv.new(csv_path, LogoImportItem)
       .import user: "Vasiliki Gkatziaki", error_policy: :report
