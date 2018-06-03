include_set Abstract::TwoColumnLayout
include_set Abstract::Listing
include_set Abstract::BsBadge

card_accessor :wikirate_company, type: :pointer
card_accessor :wikirate_topic, type: :pointer
card_accessor :project, type: :pointer
card_accessor :body
card_accessor :discussion

format :html do
  before :content_formgroup do
    voo.edit_structure = [
      :wikirate_company,
      :wikirate_topic,
      :project,
      :body
    ]
  end

  view :rich_header_body, template: :haml

  view :open_content do
    two_column_layout 7, 5
  end

  view :data do
    output [field_nest(:body),
            field_nest(:discussion, view: :titled, title: "Discussion")]
  end

  def tab_list
    %i[wikirate_company wikirate_topic project]
  end

  def tab_options
    tab_list.each_with_object({}) do |tab, hash|
      hash[tab] = { count: card.send("#{tab}_card").count }
    end
  end

  %i[wikirate_company wikirate_topic project].each do |codename|
    view :"#{codename}_tab" do
      field_nest codename, items: { view: :listing }
    end
  end

  view :listing_bottom do
    nest card.body, view: :content
  end

  view :listing_middle do
    ""
  end

  view :listing_left do
    render_title_link
  end

  view :listing_right, cache: :never do
    wrap_with :span do
      %i[wikirate_company wikirate_topic project].map do |codename|
        standard_badge codename
      end
    end
  end

  view :closed_content do
    ""
  end

  def standard_badge codename
    labeled_badge standard_count(codename), standard_title(codename)
  end

  def standard_title codename
    nest Card[codename], view: :title
  end

  def standard_count codename
    card.send("#{codename}_card").count
  end
end
