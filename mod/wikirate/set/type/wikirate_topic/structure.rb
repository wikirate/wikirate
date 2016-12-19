include_set Abstract::WikirateTable
include_set Abstract::TwoColumnLayout


def topic_name
  cardname.left_name
end

def topics_by_metric_count
  []
end

format :html do
  def default_content_formgroup_args _args
    voo.edit_structure = [:image]
  end

  def tab_list
    {
      details_tab: two_line_tab("Details", fa_icon("info")),
      companies_tab: tab_count_title(:wikirate_company),
      projects_tab: tab_count_title(:project)
    }
  end

  view :data, cache: :never do
    metric_tab
  end

  def metric_tab
    wrap do
      [metric_filter, metric_table]
    end
  end

  def metric_filter
    field_subformat(:topic_metric_filter)._render_core
  end

  view :details_tab do
    field_nest :general_overview, view: :titled
  end

  view :companies_tab do
    field_nest :wikirate_company, view: :company_list_with_metric_counts
  end

  view :projects_tab do
    field_nest :project, items: { view: :listing }
  end

  view :company_list_with_metric_counts do
    wrap do
      card.topics_by_metric_count.map do |company_card, metric_count|
        wrap_with :div, class: "company-item contribution-item" do
          [wrap_with(:div, company_detail(company_card), class: "header"),
           wrap_with(:div, class: "data") do
             metric_count_detail(company_card, metric_count)
           end]
        end
      end
    end
  end

  def company_detail company_card
    nest company_card, view: :thumbnail
  end

  def metric_count_detail company_card, metric_count
    wrap_with :span, class: "metric-count-link" do
      link_to_card(
        card.topic_name,
        "#{metric_count} #{:metric.cardname.vary :plural}",
        path: { filter: { wikirate_company: company_card.cardname.url_key } }
      )
    end
  end
end
