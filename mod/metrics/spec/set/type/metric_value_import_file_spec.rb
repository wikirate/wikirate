RSpec.describe Card::Set::Type::MetricValueImportFile do
  let(:comment) { "50 Nerds of Grey" }
  let(:metric) { sample_metric }
  let(:amazon) { "#{metric.name}+Amazon.com, Inc.+2015" }
  let(:apple)  { "#{metric.name}+Apple Inc.+2015" }
  let(:sony) { "#{metric.name}+Sony Corporation+2015" }
  let(:mv_import_file) do
    test_csv = File.open File.expand_path("../import_test.csv", __FILE__)
    Card.create! name: "does it matter?",
                 metric_value_import_file: test_csv,
                 type_id: Card::AnswerImportFileID
  end

  def fill_env_params with_comment=false
    Card::Env.params[:import_data] = []
    ["Amazon.com, Inc.", "Apple Inc.",
     "Sony Corporation"].each.with_index do |company, i|
      hash = {
        row: i + 1,
        metric: metric.name, company: company, year: "2015",
        file_company: company,
        value: i.to_s,
        source: "http://example.com"
      }
      hash[:comment] = comment if with_comment
      Card::Env.params[:import_data].push hash.to_json
    end
    Card::Env.params["is_data_import"] = "true"
  end

  before do
    login_as "joe_user"
    fill_env_params true
  end
  describe "import metric values" do
    def run_import
      mv_import_file.update_attributes! subcards: {}
    end

    let(:amazon_2015_metric_value_card) { Card["#{amazon}+value"] }
    let(:apple_2015_metric_value_card) { Card["#{apple}+value"] }

    it "adds metric values" do
      run_import
      expect(Card.exists?(amazon)).to be true
      expect(Card.exists?(apple)).to be true
      expect(amazon_2015_metric_value_card.content).to eq("0")
      expect(apple_2015_metric_value_card.content).to eq("1")
    end

    it "adds the comment" do
      run_import
      amazon_metric_discussion_card = Card["#{amazon}+discussion"]
      apple_metric_discussion_card = Card["#{apple}+discussion"]
      expect(amazon_metric_discussion_card.content).to include(comment)
      expect(apple_metric_discussion_card.content).to include(comment)
    end

    it "handles import without comment" do
      fill_env_params false
      run_import
      expect(Card.exists?(amazon)).to be true
      expect(Card.exists?(apple)).to be true
      expect(amazon_2015_metric_value_card.content).to eq("0")
      expect(apple_2015_metric_value_card.content).to eq("1")
    end

    it "marks value in action as imported" do
      run_import
      action_comment = amazon_2015_metric_value_card.actions.last.comment
      expect(action_comment).to eq "imported"
    end

    it "marks value in answer table as imported" do
      run_import
      answer_id = amazon_2015_metric_value_card.left_id
      answer = Answer.find_by_answer_id(answer_id)
      expect(answer.imported).to eq true
    end

    def add_three_answers company
      Card::Env.params[:import_data] ||= []
      3.times do |i|
        hash = {
          row: i + 1,
          metric: metric.name, company: company, year: (2015 + i).to_s,
          file_company: company,
          value: i.to_s,
          source: "http://example.com"
        }
        Card::Env.params[:import_data].push hash.to_json
      end
      Card::Env.params["is_data_import"] = "true"
    end

    def badge_names
      badges = Card.fetch "Joe User", :metric_value, :badges_earned
      badges.item_names
    end

    it "awards badges" do
      expect(badge_names).not_to include "Apple Inc.+Researcher+company badge"
      Card::Env.params[:import_data] = []
      add_three_answers "Apple Inc."
      add_three_answers "Samsung"
      run_import

      expect(badge_names)
        .to include "Apple Inc.+Researcher+company badge",
                    "Samsung+Researcher+company badge"
    end

    context "company correction name is filled" do
      let(:amazon_corrected) { "Amazon.com, Inc. Corrected" }

      before do
        Card::Env.params[:corrected_company_name] = {
          "1" => amazon_corrected,
          "2" => "",
          "3" => ""
        }
        mv_import_file.update_attributes! subcards: {}
      end

      it "uses the input company name" do
        expect(Card.exists?(amazon_corrected)).to be true

        amazon_2015_metric_value_card =
          Card["#{metric.name}+#{amazon_corrected}+2015+value"]
        expect(amazon_2015_metric_value_card.content).to eq("0")
      end

      it "updates companies's aliases" do
        amazon_aliases = Card["#{amazon_corrected}+aliases"]
        expect(amazon_aliases.item_names).to include("Amazon.com, Inc.")
      end
    end
  end
end
