require_relative "../.."
require_relative "relationship_answer"

class RelationshipAnswersCSVFile < CSVFile
  @columns = [:designer, :title, :company_1, :company_2, :year, :value, :source]

  def process_row row
    RelationshipAnswerCSVRow.new(row).create
  end
end
