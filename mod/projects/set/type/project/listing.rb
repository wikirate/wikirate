include_set Abstract::FilterableBar

format :html do
  bar_cols 8, 4

  view :bar_left do
    text_with_image image: card.field(:image),
                    size: :small,
                    title: filterable(:project) { render_title_link },
                    text: organizational_details
  end

  view :bar_middle, template: :haml

  view :bar_right do
    [count_badges(:wikirate_company, :metric),
     labeled_badge(card.percent_researched, "% Researched")]
  end

  view :bar_bottom do
    [main_progress_bar, project_details]
  end

  def organizational_details
    wrap_with :div, class: "organizational-details" do
      [field_nest(:organizer, view: :credit)]
    end
  end

  def subproject_detail
    return if card.parent.blank?
    labeled_field :parent, :link, title: "Subproject of"
  end
end
