shared_context "table_row" do |type_id|
  def csv_row args={ match_type: "exact" }
    row_args =csv_data.merge args

    AnswerCSVRow.new(row_args, 1, {},
                     match_type: row_args.delete(:match_type))
  end

  let(:format) do
    Card.new(name: "I", type_id: type_id).format(:html)
  end

  let(:row) do
    described_class.new(row_data, format).render
  end

  def field name
    index = Card::Set::Type::MetricValueImportFile::COLUMNS.keys.index(name)
    row[:content][index]
  end

  def be_disabled
    have_tag :input, with: { name: "import_data[1][import]",
                             value: true, disabled: "disabled" }
  end
end
