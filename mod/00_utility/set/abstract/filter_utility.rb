
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

def wql_by_name wql, name
  return unless name.present?
  wql[:name] = ["match", name]
end

def wql_by_project wql, project
  return unless project.present?
  wql[:referred_to_by] = { left: { name: project } }
end

def wql_by_industry wql, industry
  return unless industry.present?
  wql[:left_plus] = [
    format.industry_metric_name,
    { right_plus: [
      format.industry_value_year,
      { right_plus: ["value", { eq: industry }] }
    ] }
  ]
end
