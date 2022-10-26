
if (ENV["CARD_LOAD_STRATEGY"] == "tmp_files") && ENV["CARD_NO_COVERAGE"] != "true"
  SimpleCov.start do
    add_filter "tmp/set/gem"
    add_filter "tmp/set_pattern"
    add_filter "vendor"

    def add_mod_groups dir_pattern
      Dir[dir_pattern].each do |path|
        modname = File.basename path
        next if modname == "recycling"
        add_group "Mod: #{modname}", %r{(mod/|mod\d{3}-)#{modname}}
      end
    end

    add_mod_groups "mod/*"
    add_filter "mod/recycling"
    add_filter "/spec/"
    add_filter "/features/"
    add_filter "/config/"
    add_filter "/tasks/"
  end
end
