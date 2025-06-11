include_set Abstract::DesignerPermissions

format :html do
  def basic_table_properties
    { topic: "Topics" }.merge super
  end

  def basic_edit_properties
    { topic: "Topics",
      license: "License" }.merge super
  end

  def edit_properties
    super.merge(value_type_properties).merge(research_properties)
  end

  def table_properties
    super.merge(value_type_properties).merge(research_properties)
  end
end
