
class << self
  def require_fields fieldcodes, opts={}
    fieldcodes.each do |fieldcode|
      require_field fieldcode, opts
    end
  end

  def require_field fieldcode, opts={}
    opts = opts.reverse_merge on: :save
    event :"require_#{fieldcode}_field", :validate, opts do
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

require_field :file
require_field :report_type, when: :report_type_check_required?
require_fields %i[wikirate_title wikirate_company year], when: :check_required?

def check_required?
  !(import_act? || skip_requirements?)
end

def skip_requirements?
  skip == :requirements
end

def report_type_check_required?
  direct? && !skip_requirements?
end

# NOT adding a source via import or within research page
def direct?
  return false if import_act?
  success = Env.params[:success]
  !(success.is_a?(Hash) && success[:view] == "source_selector")
end
