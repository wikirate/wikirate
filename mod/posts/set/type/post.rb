card_accessor :body
card_accessor :discussion

format :html do
  view :rich_header_body, template: :haml

  view :data do
    output [field_nest(:body),
            field_nest(:discussion, view: :titled, title: "Discussion")]
  end

  mini_bar_cols 6, 6
  bar_cols 4, 4, 4

  view :bar_bottom do
    nest card.body_card, view: :content
  end

  view :bar_left do
    render_title_link
  end

  view :one_line_content do
    ""
  end
end
