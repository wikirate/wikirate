def year
  name.parts[-2]
end

def value
  content
end

def raw_value
  content
end

format :html do
  def input_type
    :text_field
  end
end
