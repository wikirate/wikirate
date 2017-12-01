include_set Abstract::HamlFile

format :html do
  COMMUNITIES = ["NGOs", "Researchers", "Education", "Companies",
                 "Standard Bodies", "Volunteers", "Investors", "Press"].freeze
  def haml_locals
    { communities: COMMUNITIES }
  end

  def community_link index
    name = "WikiRate for #{COMMUNITIES[index]}"
    link_to_card name,
                 nest([name, :community]),
                 class: "inherit-anchor"
  end

  def edit_fields
    COMMUNITIES.map do |com|
      ["WikiRate for #{com}+community", { absolute: true }]
    end
  end
end
