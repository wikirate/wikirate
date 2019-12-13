include_set Abstract::Researched

# OVERRIDES
def standard?
  true
end

def researched?
  true
end

format :html do
  def fixed_thumbnail_subtitle
    "Research #{research_policy_icon_link}"
  end

  def research_policy
    @research_policy ||= card.research_policy_card.item_names.first.downcase
  end

  def research_policy_icon
    mapped_icon_tag research_policy.tr(" ", "_").to_sym
  end

  def research_policy_icon_link
    return unless research_policy

    link_to_card research_policy, research_policy_icon, title: research_policy
  end
end
