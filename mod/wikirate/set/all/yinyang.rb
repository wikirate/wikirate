format do
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
