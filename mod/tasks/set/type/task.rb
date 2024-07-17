include_set Abstract::Header
include_set Abstract::Thumbnail

card_accessor :discussion
card_accessor :search_type, type: :search_type

format :html do
  before :content_formgroups do
    voo.edit_structure = %i[image description why how_to search_type]
  end

  view :header do
    render_rich_header
  end

  view :bar_left do
    render_thumbnail
  end

  view :bar_right, cache: :never do
    ""
    # labeled_badge card.search_type_card.count, "Items"
  end

  view :core, template: :haml

  def header_text
    field_nest :description
  end

  def header_title
    "#{link_to_card card.type_id}: #{render_title_link}"
  end

  def thumbnail_subtitle
    field_nest :description
  end
end
