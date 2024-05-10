include_set Abstract::List

def corporate_identifier
  right
end

format do
  def multiple?
    card.corporate_identifier.multiple?
  end
end

format :html do
  def input_type
    multiple ? :list : :text_field
  end
end

format :data do
  view :core do

  end
end