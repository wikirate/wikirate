# NOTE: name validations are in name.rb

def source_required?
  force_source_not_required? ? false : (standard? || hybrid?)
end

# hidden functionality:
# if you add a +tag card to the metric and make the first item "no source",
# then source is not required.
def force_source_not_required?
  metric_card&.fetch(:wikirate_tag)&.first_name&.key == "no_source"
end

# TODO: find this a better home
def number? str
  true if Float(str)
rescue StandardError
  false
end
