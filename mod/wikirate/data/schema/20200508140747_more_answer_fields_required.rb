class MoreAnswerFieldsRequired < Cardio::Migration::Schema
  REQUIRED_ANSWER_COLUMNS =
    %i[metric_id designer_id company_id metric_type_id year
       metric_name company_name answer_name creator_id]

  REQUIRED_RELATIONSHIP_COLUMNS =
    %i[metric_id inverse_metric_id subject_company_id object_company_id year
       subject_company_name object_company_name answer_id inverse_answer_id]

  def change
    add_index :answers, %i[metric_id company_id year], unique: true
    add_index :answers, %i[metric_id company_id]
    REQUIRED_ANSWER_COLUMNS.each do |column|
      change_column_null :answers, column, false
    end

    add_index :relationships, %i[metric_id subject_company_id object_company_id year],
              unique: true, name: "relationship_component_cards_index"
    REQUIRED_RELATIONSHIP_COLUMNS.each do |column|
      change_column_null :relationships, column, false
    end
  end
end

=begin

REQUIRED_ANSWER_COLUMNS.each do |column|
  bads = Answer.where(column => nil)
  puts "BEFORE: #{bads.count} answers have null in #{column}"
  # bads.each { |a| a.refresh column }
  # puts "AFTER: #{bads.count} answers have null in #{column}"
end

REQUIRED_RELATIONSHIP_COLUMNS.each do |column|
  bads = Relationship.where(column => nil)
  puts "BEFORE: #{bads.count} relationships have null in #{column}"
  # bads.each { |a| a.refresh column }
  # puts "AFTER: #{bads.count} relationships have null in #{column}"
end

=end
