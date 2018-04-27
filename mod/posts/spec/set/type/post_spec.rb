# -*- encoding : utf-8 -*-

describe Card::Set::Type::Post do
  %i[open_content listing edit
     wikirate_company_tab wikirate_topic_tab project_tab].each do |view|
    describe "view: #{view}" do
      it "has no errors" do
        expect_view(view).to lack_errors
      end
    end
  end
end
