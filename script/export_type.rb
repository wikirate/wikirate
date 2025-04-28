require File.expand_path "../script_helper.rb", __FILE__

CARDTYPE = ARGV.shift

unless %w[company metric topic].include? CARDTYPE
  puts "USAGE: ruby ./script/export_type CARDTYPE # (metric, company, or topic)"
  exit CARDTYPE.nil? ? 0 : 1
end

puts CARDTYPE.to_sym.card.format(:json).render_all

exit 1
