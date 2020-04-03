include_set Abstract::Researched

def inverse_card
  fetch(:inverse).first_card
end

def inverse
  fetch(:inverse).first_name
end

def inverse_title
  Card.fetch([metric_title, :inverse])&.first_name
end

def relationship?
  true
end

def simple_value_type_code
  :number
end

format :html do
  def value_legend _html=true
    "related companies"
  end
end
