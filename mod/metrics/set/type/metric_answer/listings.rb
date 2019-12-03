include_set Abstract::Media
include_set Abstract::Table

# views used in answer listings on metric, company, and profile pages

format :html do
  view :bar_left do
    wrap_with :div, class: "d-block" do
      [company_thumbnail(hide: :thumbnail_subtitle), render_metric_thumbnail]
    end
  end

  view :bar_middle do
    citations_count
  end

  view :bar_right do
    wrap_with :div, class: "d-block w-100" do
      render_concise
    end
  end

  view :bar_bottom do
    [render_chart, render_expanded_details]
  end

  view :titled_content, cache: :never do
    bs do
      layout do
        row 12 do
          column render_basic_details
        end
        row 12 do
          column render_expanded_details
        end
      end
    end
  end

  def citations_count_badge
    wrap_with :span, card.source_card&.item_names&.size, class: "badge badge-light border"
  end

  def citations_count
    wrap_with :h5, class: "w-100 text-left" do
      [citations_count_badge, "Citations"]
    end
  end

  # SHARED IN VARIOUS LISTINGS

  view :metric_thumbnail_with_bookmark do
    nest card.metric_card, view: :thumbnail_with_bookmark, hide: :thumbnail_link
  end

  view :metric_thumbnail do
    nest card.metric_card, view: :thumbnail, hide: %i[bookmark thumbnail_subtitle]
  end

  view :company_thumbnail do
    company_thumbnail hide: :thumbnail_link
  end

  def company_thumbnail nest_args={}
    nest_args.reverse_merge! view: :thumbnail
    wrap_with :div, (nest card.company_card, nest_args), class: "company-link"
  end

  def handle_unknowns
    return yield if card.known?

    render(card.researchable? ? :research_button : :not_researched)
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
        [calculated { nest card.value_card, view: :pretty }, render_flags]
      end
    end
  end

  view :year_and_icon do
    wrap_with :span, class: "answer-year" do
      "#{fa_icon :calendar} #{card.year}"
    end
  end

  view :not_researched, perms: :none, wrap: :em do
    "Not Researched"
  end

  view :plain_year do
    card.year
  end

  def calculated
    card.calculating? ? calculating_icon : yield
  end

  def calculating_icon
    fa_icon :calculator, title: "calculating ...", class: "fa-spin px-1"
  end

  def legend
    nest card.metric_card, view: :legend
  end

  view :legend do
    legend
  end

  view :legend_core do
    nest card.metric_card, view: :legend_core
  end
end
