include_set Abstract::List

def item_references?
  false
end

def company_identifier
  right
end

format do
  def multiple?
    card.company_identifier.multiple?
  end
end

format :json do
  view :core do
    if multiple?
      super()
    elsif card.real?
      render_raw
    end
  end
end

format :csv do
  view :content do
    card.item_names(context: :raw).join ";"
  end
end

format :html do
  def input_type
    multiple? ? :list : :text_field
  end

  view :hover_field, template: :haml
end
