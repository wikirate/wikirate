format :html do
  view :core, async: true do
    oc ? _render_table : _render_oc_error
  end

  view :table, template: :haml

  view :original_link do
    original_link oc.url
  end

  view :oc_error do
    alert :warning, true do
      @error || "couldn't connect to open corporates"
    end
  end

  def oc
    binding.pry
    return unless company_number.present? && jurisdiction_code.present?
    @oc ||= OCCompany.new jurisdiction_code, company_number
  rescue ArgumentError, StandardError => e
    @error = e.message
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
      ["Incorporation date", oc.incorporation_date],
      ["Company Type", oc.company_type],
      ["Status", oc.status]
    ]
  end

  def jurisdiction
    (jur = Card[jurisdiction_code]) && jur.name
  end
end
