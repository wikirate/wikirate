def project_name
  name.left_name
end

def pointer_mark
  project_name.field :metric
end

def cql_content
  super.merge append: project_name
end

format :html do
  # don't add quick filters for other projects
  def project_quick_filters
    []
  end

  def export_formats
    []
  end
end
