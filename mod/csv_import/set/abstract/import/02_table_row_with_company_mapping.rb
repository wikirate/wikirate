#! no set module

# A {TableRow} variant with an interface to handle the mapping of company entries
# to the existing companies in the wikirate database.
class TableRowWithCompanyMapping < TableRow
  # @param data [Hash] { column_name => column_value }
  attr_reader :match_type

  def initialize csv_row, format
    super
    @match = match_company
    @wikirate_company, @match_type = @match.match
    @company = @match.suggestion
  end

  def render
    super.merge class: "table-#{row_context}"
  end

  private

  def checked?
    !@match.none?
  end

  def company_correction_field
    return @match.suggestion if @match.exact? || @match.alias?
    @format.text_field_tag input_name(:corrections, :company),
                           @match.suggestion,
                           class: "company_autocomplete"
  end

  def wikirate_company_field
    @format.wrap_with :small, @match.match_name
  end

  def company_field
    @format.wrap_with :small, super
  end

  def extra_data
    {
      match_type: @match.match_type,
      company_suggestion: @match.suggestion
    }
  end

  # @return name of company in db that matches the given name and
  # the what kind of match
  def match_company
    name = @csv_row[:company]
    @company_matcher ||= {}
    @company_matcher[name] ||= CompanyMatcher.new(name)
  end

  def row_context
    return "danger" unless valid?

    case @match_type
    when :partial then "info"
    when :exact   then "success"
    when :none    then "warning"
    when :alias   then "active"
    end
  end
end
