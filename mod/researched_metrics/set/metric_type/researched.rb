include_set Abstract::Researched

# OVERRIDES
def standard?
  true
end

def researched?
  true
end

format :html do
  def thumbnail_subtitle
    "Research | #{research_policy}"
  end

  def research_policy
    card.research_policy_card.item_names.first.downcase
  end
end
