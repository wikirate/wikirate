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

  # def render
  #   super.merge class: "table-#{row_context}"
  # end

  private

  def checked?
    !@match.none?
  end

  def company_correction_field
    return @match.suggestion if @match.exact? || @match.alias? || !valid?
    colored company_correction_input(:company,  @match.suggestion)
  end

  def wikirate_company_field
    colored_small @match.match_name
  end

  def company_field
    colored_small super
  end

  def extra_data
    {
      company_match_type: @match.match_type,
      company_suggestion: @match.suggestion
    }
  end

  def company_correction_input field_key, default
    @format.text_field_tag corrections_input_name(field_key), default,
                           class: "company_autocomplete"
  end

  def colored_small content, match=@match
    colored @format.wrap_with(:small, content), match
  end

  def colored content, match=@match
    { content: content, class: row_context(match) }
  end


  # @return name of company in db that matches the given name and
  # the what kind of match
  def match_company field=:company
    name = @csv_row[field]
    @company_matcher ||= {}
    @company_matcher[name] ||= CompanyMatcher.new(name)
  end

  def row_context match=@match
    return :danger unless valid?
    return :active if imported?

    case match.match_type
    when :partial then "info"
    when :exact   then "success"
    when :none    then "warning"
    when :alias   then "alias"
    end
  end
end
