include_set Abstract::Media
include_set Abstract::Table
include_set Abstract::AnswerDetailsToggle

# views used in answer listings on metric, company, and profile pages

format :html do
  view :bar_left do
    wrap_with :div, class: "d-block" do
      [render_metric_thumbnail, company_thumbnail]
    end
  end

  view :bar_middle do
    value = wrap_with :div, render_concise, class: "d-block w-100"
    link_to_card card, value
  end

  view :bar_bottom do
    output [render_chart, render_expanded_details]
  end

  view :bar_right do
    citations_count
  end

  view :titled_content, cache: :never do
    voo.hide! :chart # hide it in value_field
    bs do
      layout do
        row 12 do
          column render_basic_details
        end
        row 12 do
          column render_chart
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
    wrap_with :div, class: "w-100 text-left" do
      [citations_count_badge, "Citations"]
    end
  end

  # ANSWER LISTINGS ON RECORDS
  # company and/or profile are detailed separately,
  # so details only include value, year, etc.

  # TODO: move to haml
  view :basic_details do
    wrap_with :div, class: "value text-align-left" do
      [
        nest(card.value_card, view: :pretty_link),
        wrap_with(:span, legend, class: "metric-unit"),
        _render_flags,
        _render_chart
      ]
    end
  end

  view :details do
    if card.relationship?
      voo.hide! :answer_details_toggle
      voo.show! :expanded_details
    else
      class_up "vis", "pull-right"
    end
    super()
  end

  # ANSWER LISTINGS ON HOME PAGE
  # perhaps not long for this world

  view :metric_thumbnail_minimal do
    nest card.metric_card, view: :thumbnail_minimal,
                           hide: [:thumbnail_subtitle, :vote]
  end

  view :company_thumbnail_minimal do
    nest card.company_card, view: :thumbnail_minimal,
                            hide: [:thumbnail_subtitle, :vote]
  end

  # SHARED IN VARIOUS LISTINGS

  view :metric_thumbnail_with_vote do
    nest card.metric_card, view: :thumbnail_with_vote, hide: :thumbnail_link
  end

  view :metric_thumbnail do
    nest card.metric_card, view: :thumbnail, hide: [:vote, :thumbnail_subtitle]
  end

  view :company_thumbnail do
    company_thumbnail with_link=false
  end

  def company_thumbnail with_link=true
    nest_args = { view: :thumbnail }
    nest_args[:hide] = :thumbnail_link unless with_link
    wrap_with :div, (nest card.company_card, nest_args), class: "company-link"
  end

  view :value_cell do
    if card.unknown?
      view = research_ready? ? :research_button : :blank
      render view
    else
      render :concise
    end
  end

  view :research_button do
    link_to_card :research_page, "Research answer",
                 target: "_blank",
                 class: "btn btn-primary btn-sm research-answer-button",
                 path: { metric: card.metric, company: card.company },
                 title: "Research answer"
  end

  # TODO: unify with conciser
  # year, value, unit and flags
  view :concise, template: :haml

  # year, value, unit and flags
  view :conciser do
    return calculating_icon if card.calculating?
    year_and_value + _render_flags
  end

  view :plain_year do
    card.name.right
  end

  def calculating_icon
    fa_icon :refresh, title: "calculating ..."
  end

  def legend
    nest card.metric_card, view: :legend
  end

  view :unit do
    legend
  end

  view :unit_core do
    nest card.metric_card, view: :legend_core
  end

  def year_and_value
    <<-HTML
      #{render :year_equals}
      #{nest card.value_card, view: :pretty}
      <span class="metric-unit"> #{legend} </span>
    HTML
  end

  view :year_equals do
    "<span class=\"metric-year\">#{card.year} = </span>"
  end
end
