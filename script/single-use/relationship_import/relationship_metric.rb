class RelationshipMetric
  include Card::Model::SaveHelper

  REQUIRED = [:designer, :title, :value_type, :inverse]

  def initialize row
    @row = row
    REQUIRED.each do |key|
      raise Error, "value for #{key} missing" unless row[key].present?
    end
    @name = "#{row[:designer]}+#{row[:title]}"
    @inverse_name = "#{row[:designer]}+#{row[:inverse]}"
  end


  def create
    ensure_designer
    create_card @name, type: Card::MetricID,
                subcards: subcards
  end

  def create_inverse
    create_card @inverse_name,
                type: Card::MetricID,
                subcards: { "+metric type" => "Inverse Relationship",
                            "+inverse" => @name }
    create_title_inverse_pointer
  end

  private

  def subcards
    subs = { "+metric_type" => "Relationship", "+inverse" => @inverse_name }
    [:value_type, :options, :unit].each_with_obj(subs) do |fld, hash|
      next unless @row[fld]
      hash["+#{fld}"] = @row[fld]
    end
  end

  def create_title_inverse_pointer
    create_card [@row[:inverse], :inverse], content: @row[:title]
    create_card [@row[:title], :inverse], content: @row[:inverse]
    # valuable here?
  end

  def ensure_designer
    ensure_card @designer, type_id: Card::ResearchGroupID
  end
end
