def wql_content
  super.merge prepend: name.left
end
