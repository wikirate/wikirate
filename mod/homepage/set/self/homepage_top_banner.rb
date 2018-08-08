include_set Abstract::HamlFile

format :html do
  def haml_locals
    { companies: company_names,
      topics: topic_names,
      adjectives: adjective_names
     }
  end

  def company_names
    (Card.fetch "homepage featured companies").item_names
  end

  def topic_names
    (Card.fetch "homepage featured topics").item_names
  end

  def adjective_names
    (Card.fetch "homepage adjectives").item_names
  end
end
