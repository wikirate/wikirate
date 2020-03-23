format :json do
  view :search_brands, cache: :never do
    keyword ? search_with_keyword : "{}"
  end

  def search_with_keyword
    ids = search_by_company_name
    company_traits(ids).sort_by { |a| a[:name] }
                       .to_json
  end

  def country_search
    return [].to_json unless country_code
    company_traits(brand_ids).to_json
  end

  # TODO: if the data grows we might want sql sorting instead of ruby sorting
  # but that involves serious SQL work because we have to join the queries of
  # search_by_company_name and search_by_address
  def company_traits ids
    return [] unless ids.present?
    ids.map do |id|
      company_name = Card.fetch_name(id)
      { name: company_name, id: id, url_key: company_name.url_key }
    end
  end

  def search_by_company_name
    return [] unless brand_ids.present?
    Card.search type_id: Card::WikirateCompanyID,
                name: ["match", keyword],
                id: ["in"].concat(brand_ids),
                return: :id
  end

  def brand_ids
    @brand_ids ||= search_brand_ids
  end

  def search_brand_ids
    wql = { type_id: Card::WikirateCompanyID,
            left_plus: Card::Codename.id(:oc_is_brand_of),
            return: :id }
    Card.search wql
  end

  def keyword
    params[:keyword] if params[:keyword].present?
  end
end
