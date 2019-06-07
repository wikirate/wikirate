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

  # def add_value_link
  #   link_to_card :research_page, "#{fa_icon 'plus'} Research answer",
  #                path: { metric: card.name},
  #                class: "btn btn-primary",
  #                title: "Research answer for another year"
  # end

  # view :add_value_buttons do
  #   return unless card.user_can_answer?
  #   wrap_with :div, class: "row margin-no-left-15" do
  #     [
  #       content_tag(:hr),
  #       add_value_link
  #     ]
  #   end
  # end
end
