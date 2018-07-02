include_set Abstract::Media
include_set Abstract::Table
include_set Abstract::AnswerDetailsToggle

# views used in answer listings on metric, company, and profile pages

format :html do
  delegate :currency, to: :card

  # ACTUAL "listing" VIEW
  # not really used in listings?

  # NOTE: answer listings on profile pages need to provide light detail but
  # full "context": company, metric, year, value, etc
  # they currently use [:metric_thumbnail, :company_thumbnail, :concise]
  # but should arguably use a more standard "listing" view

  # TODO: create standard expandable listing
  view :listing do
    _render_titled
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

  # ANSWER LISTINGS ON RECORDS
  # company and/or profile are detailed separately,
  # so details only include value, year, etc.

  # TODO: move to haml
  view :basic_details do
    wrap_with :div, class: "value text-align-left" do
      [
        wrap_with(:span, currency, class: "metric-unit"),
        _render_value_link,
        wrap_with(:span, legend, class: "metric-unit"),
        _render_flags,
        _render_chart
      ]
    end
  end

  view :details_placeholder do
    ""
  end

  view :details do
    if card.relationship?
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
    nest card.metric_card, view: :thumbnail_with_vote
  end

  view :metric_thumbnail do
    nest card.metric_card, view: :thumbnail, hide: [:vote, :thumbnail_subtitle]
  end

  view :company_thumbnail do
    nest card.company_card, view: :thumbnail_no_link
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
    year_and_value + _render_flags
  end

  view :plain_year do
    card.name.right
  end

  def legend
    return if currency.present?
    nest card.metric_card, view: :legend
  end

  view :unit do
    currency || legend
  end

  def year_and_value
    <<-HTML
      #{render :year_equals}
      <span class="metric-unit"> #{currency} </span>
      #{render :pretty_value}
      <span class="metric-unit"> #{legend} </span>
    HTML
  end

  view :year_equals do
    "<span class=\"metric-year\">#{card.year} = </span>"
  end

  view :pretty_value do
    span_args = { class: "metric-value" }
    add_class span_args, grade if card.ten_scale?
    add_class span_args, :small if pretty_value.length > 5
    wrap_with :span, span_args do
      beautify(pretty_value).html_safe
    end
  end
end
