
require_field :source, when: :source_required?

def source_required?
  force_source_not_required? ? false : (standard? || hybrid?)
end

# hidden functionality:
# if you add a +tag card to the metric and make the first item "no source",
# then source is not required.
def force_source_not_required?
  metric_card.fetch(trait: :wikirate_tag)&.item_names&.first&.key == "no_source"
end
