include_set Abstract::CompanyExcerpt

def company_number
  @company_number ||= content
end

def jurisdiction_code
  @jurisdiction_code ||= left&.headquarters_jurisdiction_code
end

def excerpt_host
  "opencorporates.com"
end

format :html do
  delegate :company_number, :jurisdiction_code, to: :card

  view :core, async: true do
    if skip_excerpt?
      fallback_link
    else
      super()
    end
  end

  def oc
    @oc ||= ::OpenCorporates::Company.new jurisdiction_code, company_number
  end

  def excerpt_body
    excerpt_table
  end

  def excerpt_link_url
    oc.opencorporates_url
  end

  def excerpt_result
    return true if oc.valid?

    @excerpt_error_message = oc_error_message
    false
  end

  def skip_excerpt?
    oc_error_message&.match? "Expired"
  end

  def oc_error_message
    if company_number.blank?
      "Not yet connected to an #{render :oc_search_link} entity"
    elsif jurisdiction_code.blank?
      "Headquarters jurisdiction needed to connect to OpenCorporates"
    else
      oc.error
    end
  end

  def excerpt_table_hash
    {
      name: oc.name,
      "previous names": oc.previous_names,
      "registered address": oc.registered_address,
      "incorporation date": incorporation_date,
      "company type": oc.company_type,
      "status": oc.status
    }
  end

  view :oc_search_link, unknown: true do
    link_to_resource oc_search_url.to_s, "OpenCorporates"
  end

  def oc_search_url
    URI::HTTPS.build host: "opencorporates.com", path: "/companies",
                     query: { q: card.name.left }.to_query
  end

  def incorporation_date
    date = oc.incorporation_date
    return "" unless date
    "#{date.strftime '%-d %B %Y'} (#{time_ago_in_words(date)} ago)"
  end

  def fallback_link
    return company_number unless jurisdiction_code

    link_to company_number, href: fallback_url, target: "_blank"
  end

  def fallback_url
    "https://opencorporates.com/companies/#{jurisdiction_code}/#{company_number}"
  end
end
