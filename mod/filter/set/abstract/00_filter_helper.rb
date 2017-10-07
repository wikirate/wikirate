

def filter_hash
  @filter_hash ||= begin
    filter = Env.params[:filter]
    filter = filter.to_unsafe_h if filter&.respond_to?(:to_unsafe_h)
    filter.is_a?(Hash) ? filter : default_filter_option
  end
end

def sort_hash
  { sort: (Env.params[:sort].present? ? Env.params[:sort] : default_sort_option) }
end

def default_filter_option
  { year: :latest, value: :exist }
end

def offset
  param_to_i :offset, 0
end

format do
  delegate :filter_hash, :sort_hash, to: :card
end

format :html do
  def extra_paging_path_args
    { filter: filter_hash }.merge sort_hash
  end
end
