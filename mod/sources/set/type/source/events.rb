
class << self
  def require_fields *fieldcodes
    fieldcodes.each do |fieldcode|
      require_field fieldcode
    end
  end

  def require_field fieldcode
    event :"require_#{fieldcode}_field", :validate, on: :save do
      add_error_unless_field fieldcode
    end
  end
end

def add_error_unless_field fieldcode
  errors.add fieldcode.cardname, "required" unless field_present? fieldcode
end

def field_present? fieldcode
  field = subfield(fieldcode) || (real? && fetch(trait: fieldcode))
  field.present?
end

require_fields :file, :wikirate_title, :wikirate_company, :year

event :require_report_type_when_direct, :validate, on: :save, when: :direct? do
  add_error_unless_field :report_type
end

def direct?
  !Env.params.dig(:success, :view) == "source_tab"
end
