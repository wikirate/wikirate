
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
    card.update! subcards: {}
    card
  end

  def trigger_import_request *data
    post :update, xhr: true, params: import_params(*data).merge(id: "~#{import_card.id}")
    import_card.reload
  end

  let(:csv_file) do
    CsvFile.new csv_io, import_item_class
  end


  def row_index key
    return key if key == :all
    index = data.keys.index key
    raise StandardError, "unknown csv row: #{key}" unless index
    index
  end

  def fill_with_default_data hash
    raise "no default data defined" unless default_data.is_a?(Hash)
    default_data.merge(hash).values
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
