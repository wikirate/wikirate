def company_number
  @company_number ||= content
end

def jurisdiction_code
  @jurisdiction_code ||= left&.headquarters_jurisdiction_code
end

format :html do
  delegate :company_number, :jurisdiction_code, to: :card
  view :core, async: true do
    oc.valid? ? _render_table : render_oc_error
  end

  view :table, template: :haml

  view :original_link do
    original_link oc.opencorporates_url, class: "external-link",
                                         text: "<small>opencorporates.com</small>"
  end

  view :oc_error do
    if company_number.blank?
      "Not yet connected to an #{render :oc_search_link} entity"
    elsif jurisdiction_code.blank?
      "Country of headquarters needed to connect to OpenCorporates"
    else
      alert :warning, true do
        oc.error
      end
    end
  end

  view :oc_search_link, unknown: true do
    link_to_resource oc_search_url.to_s, "OpenCorporates"
  end

  def oc_search_url
    URI::HTTPS.build host: "opencorporates.com", path: "/companies",
                     query: { q: card.name.left }.to_query
  end

  def oc
    @oc ||= ::OpenCorporates::Company.new(jurisdiction_code, company_number)
  end

  def table_rows
    [
      ["Name", oc.name],
      ["Previous Names", oc.previous_names],
      # ["Jurisdiction", jurisdiction],
      ["Registered Address", oc.registered_address],
      ["Incorporation date", incorporation_date],
      ["Company Type", oc.company_type],
      ["Status", oc.status]
    ].map do |label, value|
      format_table_row label, value
    end.compact
  end

  def format_table_row label, value
    return unless value.present?
    [label, wrap_with(:strong, value)]
  end

  # removed this; it's duplication, and the data is actually in some ways as much wikirate
  # as OC.
  # def jurisdiction
  #   jurisdiction_code && ::OpenCorporates::RegionCache.region_name(jurisdiction_code)
  # end

  def incorporation_date
    date = oc.incorporation_date
    return "" unless date
    "#{date.strftime '%-d %B %Y'} (#{time_ago_in_words(date)} ago)"
  end
end
