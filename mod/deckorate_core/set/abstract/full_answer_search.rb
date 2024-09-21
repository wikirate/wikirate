include_set Abstract::AnswerSearch

format do
  def default_filter_hash
    { company_name: "" }
  end
end

format :html do
  FULL_ANSWER_SECONDARY_SORT = {
    metric_title: { company_name: :asc },
    company_name: { metric_title: :asc }
  }.freeze

  def header_cells
    [company_name_sort_link, metric_sort_links, answer_sort_links]
  end

  def metric_sort_links
    "#{designer_sort_link}#{title_sort_link}"
  end

  def quick_filter_list
    @quick_filter_list ||=
      bookmark_quick_filter + topic_quick_filters + dataset_quick_filters
  end

  # def default_sort_option
  #   :metric_title
  # end

  # def secondary_sort
  #   @secondary_sort ||= FULL_ANSWER_SECONDARY_SORT[sort_by] || super
  # end

  def bookmark_type
    :todo
  end

  # def bookmark_quick_filters
  #   return [] unless my_bookmarks?
  #
  #   %i[company metric].map do |codename|
  #     { bookmark: :bookmark,
  #       text: "My #{codename.cardname} Bookmarks",
  #       class: "quick-filter-by-#{codename}" }
  #   end
  # end
end
