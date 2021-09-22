# -*- encoding : utf-8 -*-

RSpec.describe Card::Set::Abstract::MetricAnswer::Research do
  specify "non-researchable metrics are not editable" do
    rendered = view :edit,
                    card: "Jedi+deadliness average+Slate Rock and Gravel Company+2005"
    aggregate_failures "no edit form" do
      expect(rendered).to have_tag("div.card-editor") do
        without_tag :input
      end
      expect(rendered).to include "Answers to this metric cannot be researched directly."
    end
  end

  # describe "view :research form" do
  #   let(:project) { Card["Evil Project"] }
  #   let(:metric) { Card["Jedi+disturbances in the Force"] }
  #   let(:company) { Card["Los Pollos Hermanos"] }
  #
  #   let :answer do
  #     name = Card::Name[metric, company, "2015"]
  #     Card.new type: :metric_answer, name: name
  #   end
  #
  #   context "when project defaults to unpublished" do
  #     before do
  #       project.unpublished_card.update! content: "1"
  #     end
  #
  #     it "defaults to unpublished", as_bot: true do
  #       Card::Env.with_params(project: project.name) do
  #         expect(answer.format.render_research_form)
  #           .to have_tag("div.RIGHT-unpublished") do
  #             with_tag "input", with: { name: "card[subcards][+unpublished][content]",
  #                                       checked: "checked" }
  #           end
  #       end
  #     end
  #   end
  # end
end
