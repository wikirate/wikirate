include_set Abstract::Researched

# OVERRIDES
def standard?
  true
end

def researched?
  true
end

def assessment
  @assessment ||= assessment_card&.first_name&.downcase
end

format :html do
  delegate :assessment, to: :card

  def metric_type_details
    "Research #{assessment_icon_link}"
  end

  def assessment_icon
    icon_tag assessment.tr(" ", "_").to_sym
  end

  def assessment_icon_link
    return unless assessment

    link_to_card assessment, assessment_icon, title: assessment
  end
end
