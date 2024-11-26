include_set Abstract::AnswerSearch

# including module must respond to
# `fixed_field`, returning a Symbol representing an AnswerQuery id filter, and
# `partner`, returning a Symbol

def table_type
  partner
end

def query_hash
  { fixed_field => left.id }
end

format do
  delegate :partner, to: :card

  # def record?
  #   filter_hash[:"#{partner}_name"]&.match?(/^\=/)
  # end

  def answer_page_fixed_filters
    { fixed_filter_field => ["~#{card.left_id}"] }
  end
end

format :json do
  def max_grid_cells
    30
  end
end

format :html do
  def scrollable?
    current_group == :none
  end

  # none and all not available on answer dashboard or datasets
  # def filter_status_options
  #   super.merge "Not Researched" => "none", "Researched and Not" => "all"
  # end

  def default_item_view
    :grouped_record
  end

  # because when opening record-grouped items, the latest is already showing
  def grouped_card_filter
    super.merge latest: 0
  end

  def customize_item_options
    { record: "Grouped by #{partner.to_s.capitalize}",
      none: "Data Points (No Grouping)" }
  end
end
