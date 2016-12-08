format :html do
  view :chart do
    vega_chart
  end

  def chartkick_chart
    data = MetricAnswer.where(metric_id: card.id, latest: true).group("CAST(value AS decimal)").count
    line_chart data, discrete: true,
               library: { hAxis: { aggregationTarget: 'category', selectionMode: :multiple } }
  end

  def vega_chart
    content_tag :div, "", id: "vis", data: { url: path(view: :vega, format: :json) }
  end
end

format :json do
  def vega_data
    if card.numeric?
      buckets_chart_data
    elsif categorical?
      category_chart_data
    end
  end

  view :vega do
    vega_json
  end

  def category_chart_data
    data = []
    value_options.each do |option|
      data << { x: option,
                y: count_category(option),
                link: filter_link(value: option) }
    end
    data
  end

  def chart_metric_id
    card.id
  end

  def buckets_chart_data
    data = []
    min = MetricAnswer.where(metric_id: chart_metric_id).minimum(:numeric_value)
    max = MetricAnswer.where(metric_id: chart_metric_id).maximum(:numeric_value)
    bucket_size = (max - min).to_f / 10
    labels = [{ text: min.to_f }]
    lower = min
    10.times do
      upper = lower + bucket_size
      labels << { text: upper.to_f }
      data << { x: limit.to_f,
                y: count_range(lower, upper),
                link: filter_link(range: { from: lower, to: upper }),
      }
      lower = upper
    end
    [data, labels]
  end

  def count_category category
    query = filtered_item_query(filter_hash)
    query.filter :value, category
    query.count
  end

  def count_range lower_bound, upper_bound
    range_condition = { range: { from: lower_bound, to: upper_bound } }
    card.filtered_item_query(filter_hash.merge(range_condition)).count
  end

  def filter_link filter_opts
    path view: :data, filter: filter_opts
  end

  def vega_json
    data, labels = vega_data
    x_axis_scale = labels ? "x_label" : "x"
    labels ||= []
    {
      width: 400,
      height: 200,
      padding: { top: 30, left: 50, bottom: 50, right: 50 },
      data: [
        { name: "table", values: data },
        { name: "x_labels", values: labels },
      ],
      scales: scales,
      axes: axes(x_axis_scale),
      marks: marks
    }
  end

  def scales
    [{ name: "x",
       type: "ordinal",
       range: "width",
       domain: { data: "table", field: "x" } },
     { name: "y",
       type: "linear",
       range: "height",
       domain: { data: "table", field: "y" },
       nice: true },
     { name: "x_label",
       type: "linear",
       range: "width",
       domain: { data: "x_labels", field: "text" },
       nice: true }
    ]
  end

  def axes x_scale
    title = card.categorical? ? "Categories" : "Ranges"
    [{ type: "x", scale: x_scale, title: title },
     { title: "Companies", type: "y", scale: "y" }]
  end


  def marks
    [{ type: "rect",
       from: { data: "table" },
       properties:
         { enter:
             { x: { scale: "x", field: "x" },
               width: { scale: "x", band: true, offset: -1 },
               y: { scale: "y", field: "y" },
               y2: { scale: "y", value: 0 } },
           update: { fill: { value: "#674ea7" } },
           hover: { fill: { value: "#b3a7d3" } } } }]
  end
end


