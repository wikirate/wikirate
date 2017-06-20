format :html do
  view :core do
    oc ? _render_table : _render_error
  end

  view :table, template: :haml

  view :original_link do
    original_link oc.url
  end

  def oc
    @oc ||= OCCompany.new company_number
  end

  def table_rows
    [
      ["Name", oc.name],
      ["Previous Names", oc.previous_names],
      ["Jurisdiction", jurisdiction],
      ["Registered Address", oc.registered_address],
      ["Incorporation date", oc.incorporation_date],
      ["Company Type", oc.company_type],
      ["Status", oc.status]
    ]
  end

  def jurisdiction
    (jur = Card[oc.jurisdiction_code]) && jur.name
  end
end
