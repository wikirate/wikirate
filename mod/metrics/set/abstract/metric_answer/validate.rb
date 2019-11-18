# NOTE: name validations are in name.rb

def source_required?
  force_source_not_required? ? false : (standard? || hybrid?)
end

# hidden functionality:
# if you add a +tag card to the metric and make the first item "no source",
# then source is not required.
def force_source_not_required?
  metric_card&.fetch(trait: :wikirate_tag)&.item_names&.first&.key == "no_source"
end

event :restore_overridden_value, :validate, on: :delete, when: :calculation_overridden? do
  overridden_value_card.update! content: nil
  answer.restore_overridden_value
end

# TODO: find this a better home
def number? str
  true if Float(str)
rescue StandardError
  false
end
