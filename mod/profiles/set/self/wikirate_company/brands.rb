format :json do
  view :brands_select2, cache: :never do
    { results: brands_select2_option_list }.to_json
  end

  def brands_select2_option_list
    if name_query.present?
      filtered_brands_list name_query
    else
      full_brands_list
    end
  end

  def filtered_brands_list query
    Card.search(name: [:match, query], return: :id,
                type_id: Card::WikirateCompanyID, limit: 0).map do |company_id|
      full_brands_lookup_hash[company_id]
    end.compact
  end

  def brand_companies_list
    @brand_companies_list ||= Card[:filling_the_gap_group, :wikirate_company]
  end

  def full_brands_list
    @full_brands_list ||=
      brands_list brand_companies_list.item_cards
  end

  def full_brands_lookup_hash
    @full_brands_lookup_hash ||=
      full_brands_list.each_with_object({}) do |item, lookup|
        lookup[item[:lookup_id]] ||= item
      end
  end

  def brands_list company_list
    base_list = company_list.map do |company|
      { id: company.id, lookup_id: company.id, text: company.name }
    end
    base_list + brands_of(company_list.map(&:id))
  end

  def brands_of company_ids
    return [] unless company_ids.present?
    Relationship.where(metric_id: Card.fetch_id(:commons_has_brands))
                .where("subject_company_id IN (#{company_ids.join ', '})").distinct
                .pluck(:subject_company_id, :object_company_id)
                .map do |holding_id, brand_id|
      { id: holding_id,
        lookup_id: brand_id,
        text: "#{brand_id.cardname} (#{holding_id.cardname})" }
    end
  end

  def name_query
    Env.params[:q] if Env.params[:q].present?
  end

  view :search_brands, cache: :never do
    keyword ? search_with_keyword : "{}"
  end

  def search_with_keyword
    ids = search_by_company_name
    company_traits(ids).sort_by { |a| a[:name] }
                       .to_json
  end

  def country_search
    return [].to_json unless region_id
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
    [Card.fetch_id("Google Inc")]
  end

  def keyword
    params[:keyword] if params[:keyword].present?
  end
end
