require_relative "../../support/shared_csv_import"
require_relative "../../support/shared_answer_import_examples"

RSpec.describe Card::Set::Type::RelationshipAnswerImportFile, type: :controller do
  routes { Decko::Engine.routes }
  before { @controller = CardController.new }

  let(:default_data) do
    {
      designer: "Jedi",
      title: "more evil",
      company: "Death Star",
      related_company: "Google Inc.",
      year: "2017",
      value: "yes",
      source: "http://google.com",
      comment: ""
    }
  end

    def gsearch term
      "http://google.com/search?q=#{term}"
    end

    let(:metric) { "Jedi+more evil" }
    let(:year) { "2017" }

    include_context "answer import" do
      let(:company_row) { 2 }
      let(:value_row) { 5 }
    end

    include_examples "answer import examples" do
      let(:import_file_type_id) { Card::RelationshipAnswerImportFileID }
      let(:attachment_name) { :relationship_answer_import_file }
      let(:import_file_name) { "relationship_answer_test" }
      let(:unordered_import_file_name) { "relationship_wrong_order" }

      def related_company_name key, _override
        key.is_a?(Symbol) ? data_row(key)[company_row + 1] : key[:related_company]
      end

      def answer_name key, override={}
        [metric, company_name(key, override), year,
         related_company_name(key, override)].join "+"
      end
    end
  end
end
