shared_context "csv import" do
  # select data from the @data hash by listing the keys or add extra data
  # by using a hash
  # @data = { three_letters: [a,b,c],
  #           three_numbers: [1,2,3] }
  # @example
  #    trigger_import :three_letters, :three_numbers
  #    trigger_import three_letters: { extra_data: { match_type: :exact } }
  def trigger_import *data
    Card::Env.params[:import_data] = import_params(*data)
    import_card_with_data.update_attributes! subcards: {}
    import_card_with_data
  end

  def trigger_import_request *data
    post :update, xhr: true, params: { id: "~#{import_card.id}",
                                       import_data: import_params(*data) }
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

  def import_card_with_rows *row_keys
    the_file = CSVFile.new csv_io(row_keys), csv_row_class
    allow(import_card).to receive(:file).and_return csv_io(row_keys)
    allow(import_card).to receive(:csv_file).and_return the_file
    import_card
  end

  def csv_io rows=nil
    if rows
      StringIO.new rows.map { |key| data[key].join "," }.join "\n"
    else
      StringIO.new data.values.map { |rows| rows.join "," }.join "\n"
    end

  end
  def row_index key
    index = data.keys.index key
    raise StandardError, "unknown csv row: #{key}" unless index
    index
  end

  def import_params *args
    if args.size == 1 && args.first.is_a?(Hash)
      args = args.first
    end

    case args
    when Array
      args.each_with_object({}) do |key, h|
        h[row_index(key)] = { import: true }
      end
    when Hash
      args.each_with_object({}) do |(key, v), h|
        h[row_index(key)] = { import: true }.merge extra_data: v
      end
    end
  end
end
