format do
  view :license do
    "Wikirate.org, " \
      "licensed under CC BY 4.0 (https://creativecommons.org/licenses/by/4.0). " \
      "See #{card_url path(mark: :attribution_guide)}."
  end
end

format :json do
  def page_details obj
    super.tap do |hash|
      hash[:license] = render_license if card.known? && hash.is_a?(Hash)
    end
  end
end
