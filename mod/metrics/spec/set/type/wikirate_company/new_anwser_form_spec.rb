describe Card::Set::Type::WikirateCompany::NewAnswerForm do

  describe "view :new_metric+value" do
    subject { sample_company.format(:html)._render_new_metric_value }

    it "renders metric side" do
      is_expected.to have_tag "div#metric-container.stick-left" do
        with_tag "div.thumbnail" do
          with_tag "a" do
            with_tag "img"
          end
        end
      end
    end

    it "renders source side" do
      is_expected.to have_tag "div.card-slot" do
        with_tag "div#source-preview-main.stick-right" do
          with_tag "div#source-form-container" do
            with_tag "div._blank_state_message" do
              with_tag :p #text: "You can add or preview source here."
            end
          end
        end
      end
    end
  end
end
