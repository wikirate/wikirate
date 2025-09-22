format :jsonld do
  def license_url metric
    nest metric.license_card, view: :url
  end

  def context
    "#{request.base_url}/context/#{card.type}.jsonld"
  end
end
