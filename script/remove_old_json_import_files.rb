def has_migration_script? _filename
  import_script = "import_" + File.basename(file, ".json") + ".rb"
  path = File.expand_path "../*_#{import_script}", Dir.pwd
  Dir.glob(path).present?
end

Dir.chdir Card::Migration.data_path do
  Dir.glob("*.json").each do |file|
    next if has_migration_script?(file)
    puts "remove #{file}"
    FileUtils.rm file
  end
end
