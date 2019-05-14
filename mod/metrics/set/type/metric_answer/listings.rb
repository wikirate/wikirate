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
    wrap_with :h5, class: "w-100 text-left" do
      [citations_count_badge, "Citations"]
    end
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

  # prominent value, less prominent year, legend, and flags
  view :concise, template: :haml, unknown: true

  # prominent year, prominent value, less prominent flags
  view :year_and_value, template: :haml
  view :year_and_value_pretty, template: :haml

  view :plain_year do
    card.year
  end

  def calculated
    card.calculating? ? calculating_icon : yield
  end

  def calculating_icon
    fa_icon :refresh, title: "calculating ..."
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
