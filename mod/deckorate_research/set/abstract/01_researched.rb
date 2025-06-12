include_set Abstract::DesignerPermissions

format :html do
  def basic_table_properties
    super.merge topic: "Topics"
  end

  def basic_edit_properties
    { license: "License",
      topic: "Topics" }.merge super
  end

  def edit_properties
    super.merge(value_type_properties).merge(research_properties)
  end

  def table_properties
    super.merge(value_type_properties).merge(research_properties)
  end
end
