shared_context "company matches" do
  let(:exact_match) { "Death Star" }
  let(:alias_match) { "Google" }
  let(:partial_match) { "Sony" }
  let(:no_match) { "New Company" }
end

shared_context "csv import" do
  # select data from the @data hash by listing the keys or add extra data
  # by using a hash
  # @data = { three_letters: [a,b,c],
  #           three_numbers: [1,2,3] }
  # @example
  #    trigger_import :three_letters, :three_numbers
  #    trigger_import three_letters: { match_type: :exact }
  def trigger_import *data
    trigger_import_with_card import_card_with_data, *data
  end

  def trigger_import_with_card card, *data
    Card::Env.params.merge! import_params(*data)
    card.update_attributes! subcards: {}
    card
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
    # allow(import_card).to receive(:file).and_return true
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
    return import_card_with_data unless row_keys.present?
    the_file = CSVFile.new csv_io(row_keys), csv_row_class
    allow(import_card).to receive(:file).and_return csv_io(row_keys)
    allow(import_card).to receive(:csv_file).and_return the_file
    import_card
  end

  def csv_io rows=nil
    if rows
      bad_keys = rows.reject { |k| data.key? k }
      raise StandardError, "unknown keys: #{bad_keys.inspect}" if bad_keys.present?
      StringIO.new rows.map { |key| data_row(key).join "," }.join "\n"
    else
      StringIO.new data.keys.map { |key| csv_row(key) }.join "\n"
    end
  end

  def row_index key
    return key if key == :all
    index = data.keys.index key
    raise StandardError, "unknown csv row: #{key}" unless index
    index
  end

  # @param *args [<Symbol>, Hash] list of keys or a hash with key and
  # extra data hash as value
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

  def data_row key
    if data[key].is_a?(Hash)
      fill_with_default_data data[key]
    else
      data[key]
    end
  end

  def csv_row key
    data_row(key).join ","
  end

  def fill_with_default_data hash
    raise "no default data defined" unless default_data.is_a?(Hash)
    default_data.merge(hash).values
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
          name: "extra_data[#{index}][company_match_type]"
        }
        with_tag :input, with: { type: :hidden, value: suggestion,
                                 name: "extra_data[#{index}][company_suggestion]" }
      end
      fields.each do |text|
        with_tag :td, text: text
      end
    end
  end
end

# define :company_row and :value_row to use
# the helper to access the original import data
shared_context "answer import" do
  def answer_name key, override={}
    Card::Name[metric, company_name(key, override), year]
  end

  def answer_card key, override={}
    Card[answer_name(key, override)]
  end

  def answer_value key
    data_row(key)[value_row]
  end

  def company_name key, override={}
    (override.present? && override[:company]) || data_row(key)[company_row]
  end

  def value_card key
    Card[answer_name(key), :value]
  end

  def expect_answer_created key, with_value: nil
    value = with_value || data_row(key)[value_row]
    expect(answer_card(key)).to exist.and have_a_field(:value).with_content(value)
  end
end
