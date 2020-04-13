shared_context "table_row" do |type_id|
  def import_item data
    csv_data.merge data
  end

  def validated_table_row data={}
    row_args = csv_data.merge data
    io = StringIO.new row_args.values.join(",")
    file = CsvFile.new io, AnswerImportItem
    vm = ValidationManager.new file, :skip
    vm.validate do |import_item|
      yield described_class.new(import_item, format).render
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
    file = CsvFile.new io, AnswerImportItem
    vm = ValidationManager.new file, :skip
    vm.validate do |import_item|
      @row = described_class.new(import_item, format).render
      yield
    end
  end
end
