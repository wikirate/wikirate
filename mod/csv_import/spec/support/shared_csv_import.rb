shared_context "csv import" do
  # select data from the @data hash by listing the keys or add extra data
  # by using a hash
  # @data = { three_letters: [a,b,c],
  #           three_numbers: [1,2,3] }
  # @example
  #    trigger_import :three_letters, :three_numbers
  #    trigger_import three_letters: { match_type: :exact }
  def trigger_import *data
    Card::Env.params.merge! import_params(*data)
    import_card_with_data.update_attributes! subcards: {}
    import_card_with_data
  end

  def trigger_import_request *data
    post :update, xhr: true, params: import_params(*data).merge(id: "~#{import_card.id}")
    import_card.reload
  end

  let(:csv_file) do
    CSVFile.new csv_io, csv_row_class
  end

  let(:import_card_with_data) do
    # Since the import happens in the intergrate_with_delay stage
    # the import card was refetched. The only way to get the fake csv file
    # in was stubbing the CSVFile.new
    allow(CSVFile).to receive(:new).and_return csv_file
    # Card.any_instance.stub(:csv_file).and_return csv_file
    Card.any_instance.stub(:file).and_return true
    import_card
  end

  let(:status) do
    Card[import_card.name, :import_status].status
  end

  let(:errors) do
    status[:errors].values.flatten
  end

  def import_card_with_rows *row_keys
    the_file = CSVFile.new csv_io(row_keys), csv_row_class
    allow(import_card).to receive(:file).and_return csv_io(row_keys)
    allow(import_card).to receive(:csv_file).and_return the_file
    import_card
  end

  def csv_io rows=nil
    if rows
      bad_keys = rows.select { |k| !data.key? k }
      raise StandardError, "unknown keys: #{bad_keys.inspect}" if bad_keys.present?
      StringIO.new rows.map { |key| data[key].join "," }.join "\n"
    else
      StringIO.new data.values.map { |rows| rows.join "," }.join "\n"
    end

  end

  def row_index key
    return key if key == :all
    index = data.keys.index key
    raise StandardError, "unknown csv row: #{key}" unless index
    index
  end

  # @param *args [<Symbol>, Hash] list of keys or a hash with key and extra data hash as value
  def import_params *args
    args = args.first if args.size == 1 && args.first.is_a?(Hash)
    args.each_with_object(import_rows: {}, extra_data: {}) do |(key, extra_data), params|
      if key.is_a? Hash
        extra_data = key[key.keys.first]
        key = key.keys.first
      end
      params[:import_rows][row_index(key)] = true unless key == :all
      params[:extra_data][row_index(key)] = extra_data if extra_data
    end
  end
end

shared_context "table row matcher" do
  def with_row index:, context:, checked:, fields:, match:, suggestion:
    checkbox_with = { type: :checkbox, name: "import_rows[#{index}]", value: "true" }
    checkbox_with[:checked] = "checked" if checked
    with_tag :tr, with: {  "data-csv-row-index" => index } do
      with_tag :td do
        with_tag :input, with: checkbox_with
        with_tag :input, with: {
          type: :hidden, value: match,
                                 name: "extra_data[#{index}][match_type]" }
        with_tag :input, with: { type: :hidden, value: suggestion,
                                 name: "extra_data[#{index}][company_suggestion]" }
      end
      fields.each do |text|
        with_tag :td, text: text
      end
    end
  end
end
