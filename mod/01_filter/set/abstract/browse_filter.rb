include_set Abstract::Filter
include_set Abstract::FilterQuery
include_set Type::SearchType

def sort?
  true
end

def shift_sort_table?
  return false if Env.params["sort"] == "name"
  true
end

def default_sort_by_key
  "metric"
end

def default_keys
  %w(metric designer wikirate_topic project year)
end

def advanced_keys
  []
end

# gather all the params keys from default and advanced
def params_keys
  default_keys + advanced_keys
end

def target_type_id
  WikirateCompanyID
end

def get_query params={}
  filter = fetch_params params_keys
  search_args = search_wql target_type_id, filter, params_keys
  sort_by search_args, Env.params["sort"] if sort?
  params[:query] = search_args
  super(params)
end

# the default sort will take the first table in the join
# I need to override to shift the sort table to the next one
def item_cards params={}
  s = query(params)
  raise("OH NO.. no limit") unless s[:limit]
  query = Query.new(s, comment)
  shift_sort_table query
  query.run
end

def shift_sort_table query
  if sort? && shift_sort_table?
    # sort table alias always stick to the first table,
    # but I need the next table
    sort = query.mods[:sort].scan(/c(\d+).db_content/).last.first.to_i + 1
    query.mods[:sort] = "c#{sort}.db_content"
  end
end

def sort_by wql, sort_by
  if sort_by == "name"
    wql[:sort] = "name"
  else
    wql[:sort_as] = "integer"
    wql[:dir] = "desc"
    wql[:sort] = {
      right: (sort_by || default_sort_by_key), right_plus: "*cached count"
    }
  end
end

def virtual?
  true
end

def raw_content
  %({ "name":"dummy" })
end