# ENV["RAILS_ENV"] = "staging"

# ENV["BUNDLE_GEMFILE"] ||= File.expand_path("../../../Gemfile")
require File.expand_path "../../../config/environment", __FILE__

SUPPLIERS_RESPECT = "Suppliers respect labour rights".freeze
RENAMED = {
  "#{SUPPLIERS_RESPECT} (wages, freedom of association etc) (direct / tier 1)" =>
    "#{SUPPLIERS_RESPECT} (wages / freedom of association etc) (direct / tier 1)",
  "#{SUPPLIERS_RESPECT} (wages, freedom of association etc) (beyond tier 1)" =>
    "#{SUPPLIERS_RESPECT} (wages / freedom of association etc) (beyond tier 1)"
}.freeze

MAPPED = {
  "Suppliers comply with laws and company’s policies" =>
    "Suppliers comply with laws and company’s policies (direct / tier 1)",
  "Prohibit use of forced labour" =>
    "Prohibit use of forced labour (direct / tier 1)",
  "Contracts include clauses on forced labour" =>
    "Contracts include clauses on forced labour (direct / tier 1)"
}.freeze

def metric
  Card["Walk_Free_Foundation+MSA_policy_revised"]
end

def rename_options
  options_card = metric.value_options_card
  puts "options_card.item_names:\n #{options_card.item_names.join "\n"}"
  RENAMED.each do |from, to|
    puts "from: #{from}, to: #{to}"
    options_card.drop_item from
    options_card.add_item to
    options_card.skip = %i[validate_no_commas_in_value_options
                           validate_value_options_match_values]
    options_card.update!({})
    update_answers_with_rename from, to
  end
end

def update_answers_with_rename from, to
  where = "metric_id = #{metric.id} and value like '%#{SUPPLIERS_RESPECT}%'"
  Answer.where(where).each do |answer|
    update_renamed_value answer, from, to
  end
end

def update_renamed_value answer, from, to
  valcard = answer.card.value_card
  return unless valcard.include_item? from
  valcard.replace_item from, to
  puts "valcard content = '#{valcard.content}'"
  valcard.save!
end

def update_mapped_options
  Answer.where(metric_id: metric.id).each do |answer|
    valcard = answer.card.value_card
    MAPPED.each { |old, new| valcard.replace_item old, new }
    valcard.save! if valcard.db_content_changed?
  end
end

Card::Auth.signin "Ethan McCutchen"
rename_options
update_mapped_options
