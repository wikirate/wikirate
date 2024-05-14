include_set Abstract::List

def corporate_identifier
  right
end

format do
  def multiple?
    card.corporate_identifier.multiple?
  end
end

format :json do
  view :core do
    if multiple?
      super
    elsif card.real?
      render_raw
    end
  end
end

format :html do
  def input_type
    multiple? ? :list : :text_field
  end
end
