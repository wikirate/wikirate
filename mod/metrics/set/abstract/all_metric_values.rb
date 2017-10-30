include_set Abstract::SortAndFilter
include_set Abstract::Table

def search args={}
  return_type = args.delete :return
  q = query(args)
  case return_type
  when :name then
    q.run.map(&:name)
  when :count then
    q.count
  else
    q.run
  end
end

format :html do
  view :core, template: :haml, cache: :never do
    class_up "card-slot", "row _filter-result-slot"
  end

  view :table, cache: :never do
    wrap do # slot for paging links
      wikirate_table_with_details(*table_args)
    end
  end
end

def query args={}
  if filter_hash.present?
    query_class.new left.id, filter_hash, sort_hash, args
  else
    query_class.default left.id, sort_hash, args
  end
end

format :html do
  def paging_view
    :table
  end
end
