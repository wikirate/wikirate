format do
  view :yinyang_list do |args|
    wrap_with :div, class: "yinyang-list #{args[:yinyang_list_class]}" do
      _render_yinyang_list_items(args)
    end
  end

  view :yinyang_list_items do |args|
    card.item_cards(prepend: main_name,
                    append: "yinyang drag item").map do |icard|
      wrap_with :div, class: "yinyang-row" do
        nest_item icard
      end
    end.join(args[:joint] || " ")
  end

  def enrich_result result
    result.map do |item_name|
      # 1) add the main card name on the left
      # for example if "Apple+metric+*upvotes+votee search" finds "a metric"
      # we add "Apple" to the left
      # because we need it to show the metric values of "a metric+apple"
      # in the view of that item
      # 2) add "yinyang drag item" on the right
      # this way we can make sure that the card always exists with a
      # "yinyang drag item+*right" structure
      Card.fetch main_name, item_name, "yinyang drag item"
    end
  end
end
