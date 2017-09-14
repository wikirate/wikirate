RSpec.describe Card::Set::Right::TabContent do
  subject { company.fetch(trait: :tab_content).format.render_core }

  let(:company) { sample_company }
  let(:company_key) { company.cardname.url_key }

  describe "view :core" do
    def tab_param val
      Card::Env.params["tab"] = val
    end

    it "renders metric tab by default" do
      is_expected.to have_tag("div",
                              with: { id: "#{company_key}+metric_page" })
    end

    context "tab param set to 'topic'" do
      before { tab_param "topic" }

      it "renders topic tab" do
        is_expected.to have_tag("div",
                                with: { id: "#{company_key}+topic_page" })
      end
    end

    context "tab param set to 'note'" do
      before { tab_param "note" }

      it "renders topic tab" do
        is_expected.to have_tag("div",
                                with: { id: "#{company_key}+note_page" })
  end
    end

    context "invalid tab param" do
      before { tab_param "wagn" }

      it "renders empty string" do
        is_expected.to eq("")
    end
    end
  end
end
