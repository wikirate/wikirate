
def search_wql type_id, opts, params_keys, return_param=nil
  wql = { type_id: type_id }
  wql[:return] = return_param if return_param
  params_keys.each do |key|
    # link_to in #page_link with name will override the path
    method_name = key.include?("_name") ? "name" : key
    send("wql_by_#{method_name}", wql, opts[key])
  end
  wql
end
