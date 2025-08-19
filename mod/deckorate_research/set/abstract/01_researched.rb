include_set Abstract::StewardPermissions

format :html do
  def basic_edit_properties
    { license: "License",
      topic: "Topics",
      topic_framework: "Framework Mappings" }.merge super
  end

  def edit_properties
    super.merge(value_type_properties).merge(research_properties)
  end

  def table_properties
    super.merge(value_type_properties).merge(research_properties)
  end
end
