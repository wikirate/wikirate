shared_examples "answer import examples" do
  before do
    login_as "joe_admin"
  end

  def create_import_card csv_file_name
    real_csv_file =
      File.open File.expand_path("../../support/#{csv_file_name}.csv", __FILE__)
    card = create "test import", type_id: import_file_type_id,
                                 attachment_name => real_csv_file
    expect_card("test import").to exist.and have_file.of_size be_positive
    card
  end

  it "imports answer" do
    trigger_import :exact_match
    expect_answer_created :exact_match
  end

  example "create new import card and import", as_bot: true do
    import_card = create_import_card import_file_name

    expect_card(answer_name(:exact_match)).not_to exist
    params = import_params exact_match: { company_match_type: :exact }
    post :update, xhr: true, params: params.merge(mark: "~#{import_card.id}")
    expect_card("#{metric}+Death Star+2017+value").to exist
  end

  example "use csv file with wrong column order but headers" do
    import_card = create_import_card unordered_import_file_name
    trigger_import_with_card import_card, :exact_match
    expect_answer_created(:exact_match)
  end

  it "generates map" do
    import_card = create_import_card import_file_name
    expect(import_card.import_map_card.map[:company]).to be_a(Hash)
  end

  it "marks value in action as imported" do
    trigger_import :exact_match
    action_comment = value_card(:exact_match).actions.last.comment
    expect(action_comment).to eq "imported"
  end

  it "marks import actions as import" do
    trigger_import :exact_match
    card = value_card(:exact_match)
    expect(card.actions.last.comment).to eq "imported"
  end

  it "imports others if one fails" do
    trigger_import :exact_match, :invalid_value
    expect_answer_created(:exact_match)
  end


end
