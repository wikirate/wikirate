include_set Abstract::FullAnswerSearch
include_set Abstract::Chart

format :html do
  def layout_name_from_rule
    :wikirate_one_full_column_layout
  end

  before :header do
    voo.title = "Answer Dashboard #{mapped_icon_tag :dashboard}"
    voo.variant = nil
  end
end


format :json do
  def default_vega_options
    { layout: { width: 700 } }
  end
end
