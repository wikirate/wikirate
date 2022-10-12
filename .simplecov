
if ENV["TMPSETS"] && ENV["COVERAGE"] != "false"
  SimpleCov.start do
    add_filter "tmp/set/core"
    add_filter "tmp/set/gem"
    add_filter "tmp/set_pattern"
    add_filter "vendor"

    def add_mod_groups dir_pattern
      Dir[dir_pattern].each do |path|
        modname = File.basename path
        add_group "Mod: #{modname}", %r{(mod/|mod\d{3}-)#{modname}}
      end
    end

    add_mod_groups "mod/*"
    add_filter "/spec/"
    add_filter "/features/"
    add_filter "/config/"
    add_filter "/tasks/"
  end
end
