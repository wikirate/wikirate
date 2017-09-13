describe Card::Set::TypePlusRight::Source::File::Import do
  before do
    login_as "joe_user"
    @source = create_source file: csv1
    Card::Env.params["is_data_import"] = "true"
  end
  let(:csv1) do
    File.open File.expand_path("../import_test.csv", __FILE__)
  end
  let(:csv2) do
    File.open File.expand_path("../import_test.csv2", __FILE__)
  end
  let(:metric) { "Access to Nutrition Index+Marketing Score" }

  def answer_exists? company
    Card.exists?(answer_name(company))
  end

  def metric_value company
    Card[answer_name(company) + "+value"].content
  end

  def answer_card company
    Card[answer_name(company)]
  end

  def answer_name company
    metric + "+" + company_name(company) + "+2015"
  end

  def alias_card company
    Card.fetch "#{company}+aliases", new: {}
  end

  def trigger_import data, file=nil
    Card::Env.params[:import_data] = data
    source = file ? create_source(file: file) : @source
    source_file = source.fetch trait: :file
    metric = Card["Access to Nutrition Index+Marketing Score"]
    trigger_source_file_update source_file, metric
    expect(source_file.errors).to be_empty
    source_file
  end

  def trigger_source_file_update source_file, metric
    source_file.update_attributes subcards: {
      "#{@source.name}+#{Card[:metric].name}" => {
        content: "[[#{metric.name}]]",
        type_id: Card::PointerID
      },
      "#{@source.name}+#{Card[:year].name}" => {
        content: "[[2015]]", type_id: Card::PointerID
      }
    }
  end

  def company_name company
    case company
    when :amazon then "Amazon.com, Inc."
    when :apple then "Apple Inc."
    when :sony then "Sony Corporation"
    else company.to_s
    end
  end

  describe "while adding metric value" do
    it "shows errors while params do not fit" do
      source_file = @source.fetch trait: :file
      source_file.update_attributes subcards: {
        "#{@source.name}+#{Card[:metric].name}" => {
          content: "[[Access to Nutrition Index+Marketing Score]]",
          type_id: Card::PointerID
        }
      }
      expect(source_file.errors).to have_key(:content)
      expect(source_file.errors[:content]).to include("Please give a Year.")

      # as local cache will be cleaned after every request,
      # this reset local is pretending last request is done
      Card::Cache.reset_soft
      source_file.update_attributes subcards: {
        "#{@source.name}+#{Card[:year].name}" => {
          content: "[[2015]]", type_id: Card::PointerID
        }
      }
      expect(source_file.errors).to have_key(:content)
      expect(source_file.errors[:content]).to include("Please give a Metric.")
    end
    describe "metric value does not fit value type" do
      it "shows errors" do
        metric = sample_metric :number
        source_file = @source.fetch trait: :file
        Card::Env.params[:import_data] = [
          { company: "Amazon.com, Inc.", value: "hello world", row: 1 }
        ]
        trigger_source_file_update source_file, metric
        err_key = "#{metric.name}+Amazon.com, Inc.+2015+value"
        err_msg = "Only numeric content is valid for this metric."
        expect(source_file.errors).to have_key(err_key.to_sym)
        expect(source_file.errors[err_key]).to include(err_msg)
      end
    end
    it "adds correct metric values" do
      trigger_import [
        { company: "Amazon.com, Inc.", value: "9" },
        { company: "Apple Inc.",  value: "62" }
      ]
      expect(answer_exists?(:amazon)).to be true
      expect(answer_exists?(:apple)).to be true

      expect(metric_value(:amazon)).to eq("9")
      expect(metric_value(:apple)).to eq("62")
    end
    context "duplicated metric value" do
      it "blocks adding" do
        metric = sample_metric :number
        source_file = @source.fetch trait: :file
        Card::Env.params[:import_data] = [
          { company: "Amazon.com, Inc.", value: "55", row: 1 },
          { company: "Amazon.com, Inc.", value: "66", row: 2 }
        ]
        trigger_source_file_update source_file, metric
        err_key = "Row 2:#{metric.name}+Amazon.com, Inc.+2015"
        err_msg = "Duplicated metric values"
        expect(source_file.errors).to have_key(err_key.to_sym)
        expect(source_file.errors[err_key]).to include(err_msg)
      end
    end
    context "existing metric value with different value" do
      it "blocks adding" do
        metric = sample_metric :number
        source_file = @source.fetch trait: :file
        Card::Env.params[:import_data] = [
          { company: "Amazon.com, Inc.", value: "55", row: 1 }
        ]
        trigger_source_file_update source_file, metric
        Card::Env.params[:import_data] = [
          { company: "Amazon.com, Inc.", value: "56", row: 1 }
        ]
        trigger_source_file_update source_file, metric
        err_key = "Row 1:#{metric.name}+Amazon.com, Inc.+2015+metric value"
        err_msg = '<a class="known-card" href="/Jedi+deadliness">value</a>'\
                  ' \'55\' exists'
        expect(source_file.errors).to have_key(err_key.to_sym)
        expect(source_file.errors[err_key]).to include(err_msg)
      end
    end
    context "existing metric value with same value" do
      context "with different source" do
        it "won't update source" do
          metric = sample_metric :number
          source_file = @source.fetch trait: :file
          Card::Env.params[:import_data] = [
            { company: "Amazon.com, Inc.", value: "55", row: 1 }
          ]
          trigger_source_file_update source_file, metric
          another_source = create_source file: csv1
          trigger_source_file_update another_source, metric
          source_card_name = "#{metric.name}+Amazon.com, Inc.+2015+source"
          source_key = Card[source_card_name].item_cards[0].key
          expect(source_key).to eq(@source.key)
        end
      end
    end
    context "company correction name is filled" do
      before do
        # things in the form will be in string, even number
        Card::Env.params[:corrected_company_name] = {
          "1" => "Apple Inc.",
          "2" => "Sony Corporation",
          "3" => "Amazon.com, Inc."
        }
        trigger_import [
          { file_company: "Amazon.com, Inc.", value: "9", row: 1 },
          { file_company: "Apple Inc.",       value: "62", row: 2 },
          { file_company: "Sony Corporation", value: "13", row: 3 }
        ]
      end

      it "uses the correction name as company names" do
        expect(answer_exists?(:amazon)).to be true
        expect(answer_exists?(:apple)).to be true
        expect(answer_exists?(:sony)).to be true

        expect(metric_value(:amazon)).to eq("13")
        expect(metric_value(:apple)).to eq("9")
        expect(metric_value(:sony)).to eq("62")
      end

      it "adds name in the request to corrected company aliases" do
        amazon_alias =
          alias_card(company_name(:amazon)).item_names(context: :raw)
        apple_alias = alias_card(company_name(:apple)).item_names(context: :raw)
        sony_alias = alias_card(company_name(:sony)).item_names(context: :raw)
        expect(amazon_alias).to include("Sony Corporation")
        expect(apple_alias).to include("Amazon.com, Inc.")
        expect(sony_alias).to include("Apple Inc.")
      end

      context "input company doesn't exist in wikirate" do
        it "creates company and the value" do
          Card::Env.params[:corrected_company_name] = {
            "1" => "Cambridge University"
          }
          trigger_import [{ company: "Cambridge", value: "800", row: 1 }]
          expect(Card.exists?("Cambridge University")).to be true
          expect(answer_exists?(:cambridge_university)).to be true
          expect(metric_value(:cambridge_university)).to eq("800")
        end
      end
    end
    context "company correction name is empty" do
      context "non-matching case" do
        it "creates company and the value" do
          trigger_import [{ company: "Cambridge", value: "800" }]
          expect(Card.exists?("Cambridge")).to be true
          expect(answer_exists?(:cambridge)).to be true
          expect(metric_value(:cambridge)).to eq("800")
        end
      end
    end
    # existing values are not updated anymore
    # context 'metric value exists' do
    #   it 'updates metric values' do
    #     trigger_import [{ company: "Amazon.com, Inc.", value:'9' }]
    #     expect(answer_exists?(:amazon)).to be true
    #     expect(metric_value(:amazon)).to eq('9')
    #
    #     trigger_import [{ company: "Amazon.com, Inc.", value: '999' }]
    #     expect(metric_value(:amazon)).to eq('999')
    #   end
    # end
  end
  # existing values are not updated anymore
  # describe 'updating metric values' do
  #   it 'updates correct metric values' do
  #     trigger_import [{ company: 'Amazon.com, Inc.', value: '9' },
  #                     { company: 'Apple Inc.', value: '62' }]
  #     expect(answer_exists?(:amazon)).to be true
  #     expect(answer_exists?(:apple)).to be true
  #
  #     expect(metric_value(:amazon)).to eq('9')
  #     expect(metric_value(:apple)).to eq('62')
  #     source_file =
  #       trigger_import  [
  #         { company: "Amazon.com, Inc.", value: "369" },
  #         { company: "Apple Inc.", value: '689' }
  #       ], test_csv2
  #     expect(source_file.errors).to be_empty
  #     expect(Card.exists?'Access to Nutrition Index+Marketing Score+Amazon.com, Inc.+2015+link').to be false
  #     expect(Card.exists?'Access to Nutrition Index+Marketing Score+Apple Inc.+2015+link').to be false
  #     expect(metric_value(:amazon)).to eq('369')
  #     expect(metric_value(:apple)).to eq('689')
  #   end
  # end
  def with_row checked, context, args
    with = { type: "checkbox", id: "import_data_",
             value: args.to_json }
    with[:checked] = "checked" if checked
    with_tag "tr[class=\"#{context}\"]" do
      with_tag "input", with: with
      with_tag "td", text: args[:file_company]
      if args[:wikirate_company].present?
        with_tag "td", text: args[:wikirate_company]
      end

      input_args = ["input", with: {
        type: "text", name: "corrected_company_name[#{args[:row]}]"
      }]
      with_tag *input_args if args[:status] != "exact"
    end
  end

  describe "while rendering import view" do
    subject { @source.fetch(trait: :file).format.render_import }

    it "shows metric select list correctly" do
      is_expected.to have_tag("div", with: {
                                card_name: "#{@source.name}+Metric"
                              }) do
        with_tag "input", with: {
          class: "d0-card-content form-control",
          id: "card_subcards_#{@source.name}_Metric_content"
        }
      end
    end
    it "shows year select list correctly" do
      is_expected.to have_tag("div", with: {
                                card_name: "#{@source.name}+Year"
                              }) do
        with_tag "input", with: {
          class: "d0-card-content form-control",
          id: "card_subcards_#{@source.name}_Year_content"
        }
      end
    end
    it "contains hidden flag is_data_import" do
      is_expected.to have_tag("input", with: {
                                id: "is_data_import", value: "true",
                                type: "hidden"
                              })
    end
    it "renders table correctly" do
      is_expected.to have_tag("table", with: { class: "import_table" }) do
        with_row false, "danger",
                 file_company: "Cambridge",
                 value: "43",
                 csv_row_index: 1,
                 wikirate_company: "",
                 status: "none",
                 company: "Cambridge",
                 row: 1
        with_row true, "info",
                 file_company: "amazon.com",
                 value: "9",
                 csv_row_index: 2,
                 wikirate_company: "Amazon.com, Inc.",
                 status: "alias",
                 company: "Amazon.com, Inc.",
                 row: 3
        with_row true, "success",
                 file_company: "Apple Inc.",
                 value: "62",
                 csv_row_index: 3,
                 wikirate_company: "Apple Inc.",
                 status: "exact",
                 company: "Apple Inc.",
                 row: 4
        with_row true, "warning",
                 file_company: "Sony",
                 value: "33",
                 csv_row_index: 4,
                 wikirate_company: "Sony Corporation",
                 status: "partial",
                 company: "Sony Corporation",
                 row: 2
      end
    end
  end
end
