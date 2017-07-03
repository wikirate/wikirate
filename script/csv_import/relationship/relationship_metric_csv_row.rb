require_relative "../csv_row"

# This class provides an interface to import relationship metrics
class RelationshipMetricCSVRow < CSVRow
  @columns = [:designer, :title, :inverse, :value_type, :value_options, :unit]
  @required = [:designer, :title, :value_type, :inverse]

  def initialize row, index
    super
    @designer = @row[:designer]
    @name = "#{@designer}+#{@row[:title]}"
    @inverse_name = "#{@designer}+#{@row[:inverse]}"
    normalize_value_options
  end

  def import
    ensure_designer
    create_or_update_card @name, type: Card::MetricID, subfields: subfields
    create_inverse
  end

  def create_inverse
    create_or_update_card @inverse_name,
                          type: Card::MetricID,
                          subfields: { metric_type: "Inverse Relationship",
                                       inverse: @name }
    create_title_inverse_pointer
  end

  private

  def subfields
    subs = { metric_type: "Relationship", inverse: @inverse_name }
    [:value_type, :value_options, :unit].each_with_object(subs) do |field, hash|
      next unless @row[field]
      hash[field] = @row[field]
    end
  end

  def create_title_inverse_pointer
    ensure_card [@row[:inverse], :inverse], content: @row[:title],
                type_id: Card::PointerID
    ensure_card [@row[:title], :inverse], content: @row[:inverse],
                type_id: Card::PointerID
    # valuable here?
  end

  def ensure_designer
    ensure_card @designer, type_id: Card::ResearchGroupID
  end

  def normalize_value_options
    return unless @row[:value_options]
    @row[:value_options] =
      @row[:value_options].split("/").map(&:strip).to_pointer_content
  end
end
