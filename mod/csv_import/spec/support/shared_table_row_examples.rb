shared_context "table_row" do |type_id|
  def csv_row data
    row_args = csv_data.merge data
    CSVRow::Structure::AnswerCSV.new row_args, 0
  end

  def validated_table_row data
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

  let(:row) do
    described_class.new(row_data, format).render
  end

  def field  name
    index = Card::Set::Type::AnswerImportFile::COLUMNS.keys.index(name)
    row[:content][index]
  end
end
