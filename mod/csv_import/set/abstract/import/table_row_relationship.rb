#! no set module

# A {TableRow} variant for relationship answers with an interface to handle
# the mapping of two company entries to the existing companies in the wikirate database.
class TableRowRelationship < TableRowWithCompanyMapping
  # @param data [Hash] { column_name => column_value }
  attr_reader :match_type
  attr_reader :related_match_type

  def initialize csv_row, format
    super
    @related_match = match_company(:related_company)
    @related_wikirate_company, @related_match_type = @related_match.match
    @related_company = @related_match.suggestion
  end

  def row_css_classes
    return super if match_type == related_match_type
    super << "_#{related_match_type}-match"
  end

  private

  def checked?
    super || @related_match.any?
  end

  def related_company_field
    colored_small super, @related_match
  end

  def related_wikirate_company_field
    colored_small @related_match.match_name, @related_match
  end

  def related_company_correction_field
    return @related_match.suggestion if @related_match.exact? || @related_match.alias? ||
                                        !valid?
    colored company_correction_input(:related_company, @related_match.suggestion),
            @related_match
  end

  def extra_data
    super.merge related_match_type: @related_match.match_type,
                related_company_suggestion: @related_match.suggestion
  end
end
