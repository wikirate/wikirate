def filter_hash
  ((filter = Env.params[:filter]) && filter.is_a?(Hash) && filter) ||
    default_filter_option
end

def sort_hash
  { sort: (Env.params[:sort].present? ? Env.params[:sort] : default_sort_option) }
end

def paging_hash
  { limit: limit, offset: offset }
end

def default_filter_option
  { year: :latest, value: :exist }
end

def limit
  card.query(search_params)[:limit]
end

def offset
  param_to_i :offset, 0
end

def paging_path_args args={}
  args.reverse_merge! paging_hash
  args[:filter] ||= {}
  args[:filter].reverse_merge! filter_hash
  args.reverse_merge! sort_hash
  args
end

format do
  delegate :filter_hash, :sort_hash, :paging_hash, to: :card
end
