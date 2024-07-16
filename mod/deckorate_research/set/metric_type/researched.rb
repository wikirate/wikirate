include_set Abstract::Researched

# OVERRIDES
def standard?
  true
end

def researched?
  true
end

def research_policy
  @research_policy ||= research_policy_card&.first_name&.downcase
end

format :html do
  delegate :research_policy, to: :card

  def metric_type_details
    "Research #{research_policy_icon_link}"
  end

  def research_policy_icon
    icon_tag research_policy.tr(" ", "_").to_sym
  end

  def research_policy_icon_link
    return unless research_policy

    link_to_card research_policy, research_policy_icon, title: research_policy
  end
end
