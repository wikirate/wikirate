shared_context "table_row" do |type_id|
  def csv_row data
    csv_data.merge data
  end

  def validated_table_row data={}
    row_args = csv_data.merge data
    io = StringIO.new row_args.values.join(",")
    file = CSVFile.new io, CSVRow::Structure::AnswerCSV
    vm = ValidationManager.new file, :skip
    vm.validate do |csv_row|
      yield described_class.new(csv_row, format).render
    end
  end

  let(:format) do
    Card.new(name: "I", type_id: type_id).format(:html)
  end

  attr_reader :row

  def field name
    index = Card::Set::Type::AnswerImportFile::COLUMNS.keys.index(name)
    @row[:content][index]
  end

  def with_row data
    row_args = csv_data.merge data
    io = StringIO.new row_args.values.join(",")
    file = CSVFile.new io, CSVRow::Structure::AnswerCSV
    vm = ValidationManager.new file, :skip
    vm.validate do |csv_row|
      @row = described_class.new(csv_row, format).render
      yield
    end
  end
end
