# SPDX-FileCopyrightText: 2022 WikiRate info@wikirate.org
#
# SPDX-License-Identifier: GPL-3.0-or-later

require_relative "../../../config/environment"
require_relative "headquarters_import_item"
require_relative "../../../mod/csv_import/lib/import_manager/script_import_manager.rb"

csv_path = File.expand_path "../data/additional_headquarter_codes.csv", __FILE__

file = Card::ImportCsv.new(csv_path, HeadquartersImportItem, col_sep: ",", headers: true)

ScriptImportManager.new(file, user: "Philipp Kuehl", error_policy: :report).import
