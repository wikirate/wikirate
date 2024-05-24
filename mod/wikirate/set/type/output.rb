include_set Abstract::DeckorateTabbed

card_accessor :image
card_accessor :description
card_accessor :uri, type: :uri
card_accessor :file, type: :file
card_accessor :output_type, type: :pointer

card_accessor :date, type: :date
card_accessor :wikirate_company, type: :pointer

format :html do
  def breadcrumb_type_item
    link_to_card :wikirate_impact
  end

  view :page do
    wrap { [naming { render_rich_header }, render_flash, render_body] }
  end

  def edit_fields
    %i[image output_type uri file date description wikirate_company]
  end

  view :box_top, template: :haml
  view :box_middle, template: :haml

  view :box_bottom, template: :haml

  view :header_left do
    wrap_with(:h1) { render_title }
  end

  view :header_middle do
    field_nest :image, view: :content, size: :large
  end

  view :body do
    wrap_with :div, class: "py-5" do
      render_details_tab
    end
  end

  view :details_tab_left do
    field_nest :description, title: "Description"
  end

  view :details_tab_right do
    [
      field_nest(:output_type, view: :labeled, title: "type", items: { view: :name }),
      field_nest(:uri, view: :labeled, title: "URI", unknown: :blank),
      field_nest(:file, view: :labeled, title: "file", unknown: :blank),
      field_nest(:date, view: :labeled, title: "date", unknown: :blank),
      # , items: { view: :name }
      field_nest(:wikirate_company, view: :labeled, unknown: :blank,
                                    title: "organization",
                                    items: { view: :thumbnail_no_subtitle })
    ]
  end
end
