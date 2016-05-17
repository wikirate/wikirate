require "colorize"

namespace :wikirate do
  namespace :add do
    desc "create folders and files for scripts or styles"
    task codefile: :environment do
      with_params(:mod, :name, :type) do |mod, name, type|
        create_content_file mod, name, type
        create_rb_file mod, name
        create_migration_file name, type
      end
    end

    desc "create folders and files for stylesheet"
    task stylesheet: :environment do
      ENV["type"] ||= "scss"
      Rake::Task["wikirate:add:codefile"].invoke
    end

    desc "create folders and files for script"
    task script: :environment do
      ENV["type"] ||= "CoffeeScript"
    Rake::Task["wikirate:add:codefile"].invoke
    end
  end
end

def with_params *keys
  return unless parameters_present?(*keys)
  values = keys.map { |k| ENV[k.to_s] }
  yield(*values)
end

def parameters_present? *env_keys
  missing = env_keys.select { |k| !ENV[k.to_s] }
  return true if missing.empty?
  missing.each do |key|
    color_puts "missing parameter:", :red, key
  end
  false
end

def color_puts colored_text, color, text=""
  puts "#{colored_text.send(color.to_s)} #{text}"
end

def write_at fname, at_line, sdat
  open(fname, "r+") do |f|
    (at_line - 1).times do    # read up to the line you want to write after
      f.readline
    end
    pos = f.pos               # save your position in the file
    rest = f.read             # save the rest of the file
    f.seek pos                # go back to the old position
    f.puts sdat          # write new data & rest of file
    f.puts rest
    color_puts "created", :green, fname
  end
end

def write_to_mod mod, relative_dir, filename
  mod_dir = File.join "mod", mod
  dir = File.join mod_dir, relative_dir
  path = File.join dir, filename
  Dir.mkdir(dir) unless Dir.exist?(dir)
  if File.exist?(path)
    color_puts "file exists", :yellow,  path
  else
    File.open(path, "w") do |opened_file|
      yield(opened_file)
      color_puts "created", :green, path
    end
  end
end

def create_content_file mod, name, type
  dir = case type.downcase
        when "js", "coffeescript" then "javascript"
        when "css", "scss" then "stylesheets"
        end
  file_ext = type == "coffeescript" ? ".js.coffee" : "." + type
  content_dir = File.join "lib", dir
  content_file = name + file_ext
  write_to_mod(mod, content_dir, content_file) do |f|
    content = (card = Card.fetch(name)) ? card.content : ""
    f.puts content
  end
end

def create_rb_file mod, name
  self_dir = File.join "set", "self"
  self_file = name + ".rb"
  write_to_mod(mod, self_dir, self_file) do |f|
    f.puts("include_set Abstract::CodeFile")
  end
end

def create_migration_file name, type
  puts "creating migration file...".yellow
  migration_out = `bundle exec wagn generate card:migration #{name}`
  migration_file = migration_out[/db.*/]
  unless (type_id = Card.fetch_id(type))
    color_puts "invalid type", :red, type
    return
  end
  codename_string =
    <<-RUBY
    create_or_update name: '#{Card.fetch(name).name}',
                     type_id: #{type_id},
                     codename: '#{name}'
  RUBY
  write_at(migration_file, 5, codename_string) # 5 is line no.
end
