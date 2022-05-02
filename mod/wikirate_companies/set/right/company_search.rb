include_set Abstract::CompanyFilter

def pointer_mark
  name.left
end

def cql_content
  { type: :wikirate_company, referred_to_by: pointer_mark }
end

format do
  def default_sort_option
    "name"
  end
end
