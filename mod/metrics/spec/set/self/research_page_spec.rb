describe Card::Set::Self::ResearchPage do
  describe "view :core" do
    before do
      Card::Env.params[:company] = "Death Star"
      Card::Env.params[:metric] = "Jedi+disturbance of the force"
    end
    subject { Card[:research_page].format(:html)._render_core }

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
              with_tag :p
            end
          end
        end
      end
    end
  end
end
