include_set Abstract::CompanySearch

def pointer_mark
  name.left
end

def cql_content
  { type: :company, referred_to_by: pointer_mark }
end

format do
  def default_sort_option
    "name"
  end
end
