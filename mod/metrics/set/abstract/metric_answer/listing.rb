format do
  view :legend, unknown: true do
    nest card.metric_card, view: :legend
  end
end

format :html do
  view :core do
    render_concise
  end

  view :bar_middle do
    ""
  end

  view :bar_right do
    wrap_with :div, class: "d-block w-100" do
      render_concise
    end
  end

  view :metric_thumbnail_with_bookmark do
    nest card.metric_card, view: :thumbnail_with_bookmark, hide: :thumbnail_link
  end

  view :metric_thumbnail do
    nest card.metric_card, view: :thumbnail, hide: :thumbnail_subtitle
  end

  # prominent value, less prominent year, legend, and flags
  view :concise, unknown: true do
    handle_unknowns { haml :concise }
  end

  # prominent year, prominent value, less prominent flags
  view :year_and_value, unknown: true, template: :haml
  view :year_and_value_pretty, unknown: true, template: :haml

  view :value_and_flags, unknown: true do
    wrap_with :div, class: "value-and-flags" do
      handle_unknowns do
        [nest(card.value_card, view: :pretty), render_flags]
      end
    end
  end

  view :year_and_icon do
    wrap_with :span, class: "answer-year" do
      "#{mapped_icon_tag :year} #{card.year}"
    end
  end

  view :not_researched, perms: :none, wrap: :em do
    "Not Researched"
  end

  view :plain_year do
    card.year
  end

  view :research_option, perms: :none do
    card.known? ? render_concise : render_year_not_researched
  end

  view :year_not_researched, perms: :none, template: :haml

  def handle_unknowns
    return yield if card.known?

    render(card.researchable? ? :research_button : :not_researched)
  end

  def company_thumbnail company, nest_args={}
    nest_args.reverse_merge! view: :thumbnail
    wrap_with :div, (nest company, nest_args), class: "company-link"
  end
end
