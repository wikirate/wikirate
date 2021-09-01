include_set Abstract::TwoColumnLayout

card_accessor :wikirate_company, type: PointerID
card_accessor :wikirate_topic, type: PointerID
card_accessor :dataset, type: PointerID
card_accessor :body
card_accessor :discussion

format :html do
  before :content_formgroups do
    voo.edit_structure = [
      :wikirate_company,
      :wikirate_topic,
      :dataset,
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

  bar_cols 6, 6
  info_bar_cols 4, 4, 4

  def tab_list
    %i[wikirate_company wikirate_topic dataset]
  end

  %i[wikirate_company wikirate_topic dataset].each do |codename|
    view :"#{codename}_tab" do
      field_nest codename, items: { view: :bar }
    end
  end

  view :bar_bottom do
    nest card.body_card, view: :content
  end

  view :bar_left do
    render_title_link
  end

  view :bar_right do
    count_badges(*tab_list)
  end

  view :one_line_content do
    ""
  end
end
