format :json do
  view :search_factories, cache: :never do
    keyword ? search_with_keyword : country_search
  end

  def search_with_keyword
    ids = search_by_company_name | search_by_address
    company_traits(ids).sort_by { |a| a[:name] }
                       .to_json
  end

  def country_search
    return [].to_json unless country_code
    company_traits(factory_ids).to_json
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
    return [] unless factory_ids.present?
    Card.search type_id: WikirateCompanyID,
                name: ["match", keyword],
                id: ["in"].concat(factory_ids),
                return: :id
  end

  def search_by_address
    return [] unless factory_ids.present?
    Answer.where(*search_by_address_sql(factory_ids)).pluck(:company_id)
  end

  ADDRESS_SQL = "metric_id = ? AND value LIKE ?".freeze

  def search_by_address_sql company_ids
    sql = if company_ids.present?
            ["company_id IN (?) AND (#{ADDRESS_SQL})", company_ids]
          else
            [ADDRESS_SQL]
          end
    sql.push(Card::Codename.id(:company_address)).push("%#{keyword}%")
  end

  def factory_ids
    @factory_ids ||= search_factory_ids
  end

  def search_factory_ids
    wql = { type_id: Card::WikirateCompanyID,
            left_plus: Card::Codename.id(:commons_supplier_of),
            return: :id }
    if country_code
      wql[:right_plus] = [{ codename: "headquarters" },
                          { refer_to: { codename: country_code.to_s } }]
    end
    Card.search wql
  end

  def country_code
    params[:country_code] if params[:country_code].present? &&
                             params[:country_code] != "undefined"
  end

  def keyword
    params[:keyword] if params[:keyword].present?
  end
end
