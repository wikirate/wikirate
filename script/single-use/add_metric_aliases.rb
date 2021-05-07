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

    def run!
      csv.each do |r|
        source = card r["Old link"]
        target = card r["New Link"]
        next if different_designer? source, target
        alias_card = Card.fetch source.name.right, new: {}
        alias_card.update! type_code: :alias, content: target.name.right
      end
    end
  end
end

MetricAliaser.run!
puts "done."
