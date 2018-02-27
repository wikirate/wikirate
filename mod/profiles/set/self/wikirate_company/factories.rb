format :json do
  view :search_factories do
    company_ids = search_by_country
    if keyword
      company_ids = search_by_company_name(company_ids) | search_by_address(company_ids)
    end
    company_ids.map { |id| Card.fetch_name(id) }.to_json
  end

  def search_by_company_name company_ids
    return company_ids unless keyword
    wql = { type_id: WikirateCompanyID, name: ["match", keyword], return: :id }
    wql[:id] = ["in"].concat(company_ids) if company_ids.present?
    Card.search wql
  end

  def search_by_address company_ids
    return company_ids unless keyword
    address_metric_id = Card.fetch_id "Clean_Clothes_Campaign+Address"
    args = if company_ids.present?
             ["company_id IN (?) AND (metric_id = ? and value LIKE ?)", company_ids]
           else
             ["metric_id = ? and value LIKE ?"]
           end
    Answer.where(*args, address_metric_id, keyword).pluck(:company_id)
  end

  def search_by_country
    return [] unless country_code
    wql = { type_id: Card::WikirateCompanyID, return: :id,
            right_plus: [{ codename: "headquarters"},
                          { refer_to: { codename: country_code.to_s } }] }
    Card.search wql
  end

  def country_code
    Env.params[:country_code]
  end

  def keyword
    Env.params[:keyword]
  end
end
