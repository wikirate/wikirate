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

  context "with no match" do
    it "creates company" do
      trigger_import no_match: { company_match_type: :none,
                                 corrections: { company: "corrected company" } }

      expect_card(answer_name(:no_match, company: "corrected company")).to exist
      expect(Card["corrected company"]).to have_type :wikirate_company
    end

    it "adds answer to corrected answer and creates new alias card" do
      expect(Card["Monster Inc", :aliases]).not_to exist
      trigger_import no_match: { company_match_type: :none,
                                 corrections: { company: "Monster Inc." } }
      expect(Card["Monster Inc."])
        .to have_a_field(:aliases).pointing_to company_name(:no_match)
    end

    it "adds company in file to corrected company's aliases" do
      trigger_import exact_match: { company_match_type: :none,
                                    corrections: { company: "Google Inc." } }
      expect_card(answer_name(:exact_match, company: "Google Inc.")).to exist
      expect(Card["Google Inc."])
        .to have_a_field(:aliases).pointing_to company_name(:exact_match)
    end
  end

  context "with partial match" do
    it "adds company name in file to corrected company's aliases" do
      trigger_import partial_match: { company_match_type: :partial,
                                      corrections: { company: "corrected company" },
                                      company_suggestion:  "Sony Corporation" }
      expect(answer_card(:partial_match, company: "corrected company")).to exist
      expect_card("corrected company")
        .to have_a_field(:aliases).pointing_to company_name(:partial_match)
    end

    it "uses suggestion if no correction" do
      trigger_import partial_match: { company_match_type: :partial,
                                      company_suggestion: "Sony Corporation" }
      expect_card(answer_name(:partial_match, company: "Sony Corporation")).to be_a Card
      expect_card("Sony Corporation")
        .to have_a_field(:aliases).pointing_to company_name(:partial_match)
    end
  end

  context "with alias match" do
    it "uses suggestion" do
      trigger_import alias_match: { company_match_type: :alias,
                                    company_suggestion: "Google Inc." }

      expect_card(answer_name(:alias_match, company: "Google Inc")).to be_a Card
      expect_card("Google").to be_unknown
      expect_card(answer_name(:alias_match, company: "Google")).to be_unknown
    end
  end

  context "with company correction name is filled" do
    it "uses the corrected company name" do
      trigger_import no_match: { corrections: { company: "corrected company" } }
      expect_card(answer_name(:no_match, company: "corrected company")).to exist
    end
  end
end
