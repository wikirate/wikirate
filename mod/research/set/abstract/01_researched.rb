include_set Abstract::DesignerPermissions

format :html do
  def edit_properties
    super.merge(value_type_properties).merge(research_properties)
  end

  def table_properties
    super.merge(value_type_properties).merge(research_properties)
  end

  def tab_list
    super.insert 2, :source
  end

  view :main_details do
    [nest_about, nest_methodology].join "<br/>"
  end

  view :source_tab do
    answer_filtering do |items|
      field_nest :source, view: :filtered_content, items: items
    end
  end
end
