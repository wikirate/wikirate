include_set Abstract::AllValues

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
end
