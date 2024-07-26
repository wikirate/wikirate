
require File.expand_path("../../self/source_spec",  __FILE__)

RSpec.describe Card::Set::All::Wikirate do
  describe "while showing view" do
    it "always shows the help text" do
      # render help text of source page
      # create a page with help text
      create "testhelptext", type: "Basic", content: "<p>hello test case</p>"
      create "testhelptext+*self+*help", type: "Basic", content: "Can I help you?"
      html = render_card :edit, name: "testhelptext"
      expect(html).to include("Can I help you?")
    end

    it "shows correct html for the menu_link view" do
      html = render_card :menu, name: "A"
      expect(html).to have_tag("i.material-icons", with_text: "yomama")
    end
  end

  # describe "progress bar view" do
  #   context "card content is numeric" do
  #     it "render progress bar" do
  #       value = "3.14159265"
  #       numeric_card = create "I am a number", content: "3.14159265"
  #       html = numeric_card.format.render_progress_bar
  #       expect(html).to have_tag("div", with: { class: "progress" }) do
  #         with_tag "div", with: { class: "progress-bar",
  #                                 "aria-valuenow" => value },
  #                         text: /#{value}%/
  #       end
  #     end
  #   end
  #   context "card content is not numeric" do
  #     it "returns error message" do
  #       non_numeric_card =
  #         Card.create! name: "I am not a number",
  #                      content: "There are 2 hard problems in computer science: " \
  #                               "cache invalidation, naming things, " \
  #                               "and off-by-1 errors."
  #       html = non_numeric_card.format.render_progress_bar
  #       expect(html)
  #         .to eq("Only card with numeric content can be shown as progress bar.")
  #     end
  #   end
  # end
end
