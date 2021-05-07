require File.expand_path "../../../config/environment", __FILE__

Card::Auth.signin "Ethan McCutchen"

require "csv"

FILENAME = File.expand_path "script/single-use/data/renamed_metrics.csv"

# create aliases for renamed metrics
module MetricAliaser
  class << self
    def csv
      CSV.new raw, headers: true
    end

    def raw
      File.read FILENAME
    end

    def card string
      name = string.gsub(%r{^.*/}, "")
      Card.fetch name, new: {}
    end

    def different_designer? source, target
      (source.name.left_name != target.name.left_name).tap do |result|
        puts "DIFFERENT DESIGNER: #{source.name} / #{target.name}" if result
      end
    end

    def add_alias from, to
      puts "adding alias from #{from} to #{to}"
      Card.fetch(from, new: {}).update! type_code: :alias, content: to
    end

    def run!
      csv.each do |r|
        source = card r["Old link"]
        target = card r["New Link"]
        next if different_designer? source, target
        source.delete! if source.real? # get rid of compound card
        add_alias source.name.right, target.name.right
      end
    end
  end
end

MetricAliaser.run!
puts "done."
