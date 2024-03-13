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

  def record?
    filter_hash[:"#{partner}_name"]&.match?(/^\=/)
  end
end

format :json do
  def max_grid_cells
    30
  end
end

format :html do
  # none and all not available on answer dashboard yet.
  def filter_status_options
    super.merge "Not Researched" => "none", "Researched and Not" => "all"
  end
end
