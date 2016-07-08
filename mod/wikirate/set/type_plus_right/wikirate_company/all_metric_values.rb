include_set Abstract::AllValues

def virtual?
  true
end

def raw_content
  %(
    {
      "left":{
        "type":"metric_value",
        "left":{
          "right":"_left"
        }
      },
      "right":"value",
      "limit":0
    }
  )
end

format do
  def num?
    false
  end
end

format :html do
  view :card_list_items do |args|
    search_results.map do |row|
      c = Card["#{row[0]}+#{card.cardname.left}"]
      render :card_list_item, args.clone.merge(item_card: c)
    end.join "\n"
  end

  view :card_list_header do
    sort_by, sort_order = card.sort_params
    company_sort_order, value_sort_order = sort_order sort_by, sort_order
    company_sort_icon, value_sort_icon = sort_icon sort_by, sort_order
    %(
      <div class='yinyang-row column-header'>
        <div class='company-item value-item'>
          #{sort_link "Metrics #{company_sort_icon}",
                      sort_by: 'company_name', order: company_sort_order,
                      class: 'header'}
          #{sort_link "Values #{value_sort_icon}",
                      sort_by: 'value', order: value_sort_order,
                      class: 'data'}
        </div>
      </div>
    )
  end

  view :metric_list do |_args|
    wrap_with :div, class: "yinyang-list" do
      render_content(hide: "title",
                     items: { view: :metric_row })
    end
  end
end
