icon_basket = basket[:icons][:wikirate] =
  %i[wikirate_company wikirate_topic company_group project dataset research_group
     metric metric_answer source].each_with_object({}) { |key, hash| hash[key] = key }

icon_basket[:data_subset] = :dataset

format :html do
  def wikirate_icon_tag icon, _opts={}
    %(<i class="wr-icon wr-icon-#{icon}"></i>)
  end
end
