include_set Abstract::AllMetricValues

def wql_to_identify_related_metric_values
  '"left": { "left":"_left" }'
end


def item_cards _args={}
  MetricAnswer.fetch(metric_id: left.id, latest: true)
end

class FilterQuery
  SIMPLE_FILTERS = ::Set.new([:metric_id, :latest, :year]).freeze

  def initialize args
    @args = args
    @conditions = []
    @values = []
    @restrict_to_ids = Hash.new { |h, k| h[k] = [] }
  end

  def where_args
    @args.each do |key, value|
      if SIMPLE_FILTERS.include? key
        filter key, value
      elsif respond_to? "#{key}_query"
        send "#{key}_query", value
      end
    end
    @restrict_to_ids.each do |key, values|
      filter key, values
    end
    [@conditions.join(" AND ")] + @values
  end

  def filter key, value, operator=nil
    operator ||= value.is_a?(Array) ? "IN" : "="
    @conditions << "#{key} #{operator} (?)"
    @values << value
  end


  def project_query value
    company_ids =
        Card.search referred_to_by: { left: { name: value },
                                      right: { codename: "wikirate_company" } },
                    return: :id
    @restrict_to_ids[:company_id] += company_ids
  end

  def industry_query value
    company_ids =
        Card.search left_plus: [
            Right::BrowseCompanyFilter::CompanyFilterQuery::INDUSTRY_METRIC_NAME,
            { right_plus: [
                Right::BrowseCompanyFilter::CompanyFilterQuery::INDUSTRY_VALUE_YEAR,
                { right_plus: ["value", { eq: value }] }
            ] }
        ],
                    return: :id
    @restrict_to_ids[:company_id] += company_ids
  end

  def name_query value
    filter :company_name, "%#{value}%", "LIKE"
  end

  def metric_value_query value
    case value.to_sym
    when :none
    else
      if (period = timeperiod(value))
        filter :updated_at, Time.now - period, ">"
      end
    end
  end

  def timeperiod value
    case value.to_sym
    when :today then
      1.day
    when :week then
      1.week
    when :month then
      1.month
    end
  end
end

def filtered_item_cards filter={}
  filter[:latest] = true unless filter[:year] || filter[:metric_value]
  where_args = FilterQuery.new(filter.merge(metric_id: left.id)).where_args
  MetricAnswer.fetch(*where_args)
end

format do
  def page_link_params
    [:name, :industry, :project, :year, :value]
  end
end

format :html do
  view :card_list_header do
    <<-HTML
      <div class='yinyang-row column-header'>
        <div class='company-item value-item'>
          #{sort_link "Companies #{sort_icon :name}",
                      sort_by: 'name', order: toggle_sort_order(:name),
                      class: 'header'}
          #{sort_link "Values #{sort_icon :value}",
                      sort_by: 'value', order: toggle_sort_order(:value),
                      class: 'data'}
        </div>
      </div>
    HTML
  end

  def item_card_from_row row
    Card.fetch "#{card.cardname.left}+#{row[0]}"
  end
end
