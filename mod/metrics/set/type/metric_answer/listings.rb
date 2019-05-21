include_set Abstract::Media
include_set Abstract::Table
include_set Abstract::AnswerDetailsToggle

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
    output [render_chart, render_expanded_details]
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
    company_thumbnail hide: :thumbnail_link
  end

  def company_thumbnail nest_args={}
    nest_args.reverse_merge! view: :thumbnail
    wrap_with :div, (nest card.company_card, nest_args), class: "company-link"
  end

  view :value_cell, unknown: true do
    view = if card.unknown?
             research_ready? ? :research_button : :blank
           else
             :concise
           end
    render view
  end

  view :research_button, unknown: true do
    link_to_card :research_page, "Research answer",
                 target: "_blank",
                 class: "btn btn-primary btn-sm research-answer-button",
                 path: { metric: card.metric, company: card.company },
                 title: "Research answer"
  end

  # prominent value, less prominent year, legend, and flags
  view :concise, template: :haml, unknown: true

  # prominent year, prominent value, less prominent flags
  view :year_and_value, template: :haml

  view :plain_year do
    card.year
  end

  def calculated
    card.calculating? ? calculating_icon : yield
  end

  def calculating_icon
    fa_icon :calculator, title: "calculating ...", class: "fa-spin"
  end

  def legend
    nest card.metric_card, view: :legend
  end

  # TODO: clean up legend handling.
  # unit is just one legend component.  very confusing for this view to be named "unit"
  # also, we are wrapping the legend with metric-unit in many places.
  # there should be one legend view with a metric-legend class.
  view :unit do
    legend
  end

  view :unit_core do
    nest card.metric_card, view: :legend_core
  end

  view :year_option, unknown: true do
    return unless card.year.present?
    card.new? ? haml(:new_year_option) : render(:year_and_value)
  end

  view :year_selected_option, template: :haml, unknown: true
end
