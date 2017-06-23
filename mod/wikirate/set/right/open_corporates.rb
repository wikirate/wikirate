format :html do
  view :core, async: true do
    oc.valid? ? _render_table : render_oc_error
  end

  view :table, template: :haml

  view :original_link do
    original_link oc.opencorporates_url, class: "external-link",
                                         text: "<small>Visit Original</small>"
  end

  view :oc_error do
    alert :warning, true do
      oc.error
    end
  end

  def oc
    @oc ||= ::OpenCorporates::Company.new(jurisdiction_code, company_number)
  end

  def company_number
    @company_number ||= card.content
  end

  def jurisdiction_code
    @jurisdiction_code ||= (left = card.left) && left.headquarters_jurisdiction_code
  end

  def table_rows
    [
      ["Name", oc.name],
      ["Previous Names", oc.previous_names],
      ["Jurisdiction", jurisdiction],
      ["Registered Address", oc.registered_address],
      ["Incorporation date", incorporation_date],
      ["Company Type", oc.company_type],
      ["Status", oc.status]
    ].map do |label, value|
      [wrap_with(:strong, label), value]
    end
  end

  def jurisdiction
    (jur = Card[jurisdiction_code]) && jur.name
  end

  def incorporation_date
    date = oc.incorporation_date
    return "" unless date
    "#{date.strftime "%d %B %Y"} (#{time_ago_in_words(date)} ago)"
  end
end
