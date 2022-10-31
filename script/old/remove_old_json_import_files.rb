# SPDX-FileCopyrightText: 2014 2014 Laureen van Breen, <laureen@wikirate.org> et al.
#
# SPDX-License-Identifier: GPL-3.0-or-later

def migration_script? _filename
  import_script = "import_" + File.basename(file, ".json") + ".rb"
  path = File.expand_path "../*_#{import_script}", Dir.pwd
  Dir.glob(path).present?
end

Dir.chdir Cardio::Migration.data_path do
  Dir.glob("*.json").each do |file|
    next if migration_script?(file)
    puts "remove #{file}"
    FileUtils.rm file
  end
end
