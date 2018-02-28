format :json do
  view :search_factories, cache: :never do
    company_ids = search_by_country
    if keyword
      company_ids = search_by_company_name(company_ids) | search_by_address(company_ids)
    end
    company_traits(company_ids).to_json
  end

  def company_traits ids
    ids.map do |id|
      company_name = Card.fetch_name(id)
      { name: company_name, id: id, url_key: company_name.url_key }
    end
  end

  def search_by_company_name company_ids
    return company_ids unless keyword
    wql = { type_id: WikirateCompanyID, name: ["match", keyword], return: :id }
    wql[:id] = ["in"].concat(company_ids) if company_ids.present?
    Card.search wql
  end

  def search_by_address company_ids
    return company_ids unless keyword
    Answer.where(*search_by_address_sql(company_ids)).pluck(:company_id)
  end

  ADDRESS_SQL = "metric_id = ? and value LIKE ?".freeze

  def search_by_address_sql company_ids
    address_metric_id = Card.fetch_id "Clean_Clothes_Campaign+Address"
    sql = if company_ids.present?
            ["company_id IN (?) AND (#{ADDRESS_SQL})", company_ids]
          else
            [ADDRESS_SQL]
          end
    sql.push(address_metric_id).push("%#{keyword}%")
  end

  def search_by_country
    return [] unless country_code
    Card.search type_id: Card::WikirateCompanyID, return: :id,
                right_plus: [{ codename: "headquarters" },
                             { refer_to: { codename: country_code.to_s } }]
  end

  def country_code
    params[:country_code] if params[:country_code].present?
  end

  def keyword
    params[:keyword] if params[:keyword].present?
  end
end
