include_set Abstract::DesignerPermissions

format :html do
  def edit_properties
    super.merge(value_type_properties).merge(research_properties)
  end

  def table_properties
    super.merge(value_type_properties).merge(research_properties)
  end

  view :source_tab do
    field_nest :source, view: :filtered_content
  end
end
