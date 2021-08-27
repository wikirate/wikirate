def task_cql
  left.search_type_card&.cql_content
end

def cql_content
  @cql_content ||= task_cql.merge limit: 8
end
