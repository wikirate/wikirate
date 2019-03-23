
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

    it "return html for an existing card for modal view" do
      card = create "test_basic", type: "html", content: "Hello World"
      Card::Env.params[:show_modal] = card.name
      expect(render_card(:wikirate_modal, name: card.name)).to eq(
        "<div class='modal-window'>#{render_card :core, name: card.name} </div>"
      )
    end

    it "return \"\" for a nonexisting card or nil card for modal view" do
      # nil card in arg
      html = render_card :wikirate_modal, name: "test1"
      expect(html).to eq("")

      Card::Env.params[:show_modal] = "test1"
      html = render_card :wikirate_modal, name: "test1"
      expect(html).to eq("")
    end

    it "shows correct html for the menu_link view" do
      html = render_card :menu, name: "A"
      expect(html).to include('<i class="material-icons">edit</i>')
    end

    it "shows empty string for not real card for raw_or_blank view" do
      html = render_card :raw_or_blank, name: "non-existing-card"
      expect(html).to eq("")
    end

    it "renders raw for real card for raw_or_blank view" do
      html = render_card :raw_or_blank, name: "home"
      expect(html).to eq(render_card(:raw, name: "home"))
    end
  end

  describe "og_source view" do
    context "with existing card" do
      it "renders source view" do
        file_path = "#{Rails.root}/mod/wikirate_assets/spec/set/all/DeathStar.jpg"
        dump_card = Card.create name: "dump is dump",
                                type_code: "image", image: File.new(file_path)
        expect(dump_card.format.render_og_source).to eq(dump_card.format.render_source)
      end
    end
    context "with nonexistent card" do
      it "renders the vertical logo link" do
        new_card = Card.new name: "orange pen phone"
        vertical_logo_source_view = Card["*vertical_logo"].format.render_source size: "large"
        expect(new_card.format.render_og_source).to eq(vertical_logo_source_view)
      end
    end
  end
  describe "progress bar view" do
    context "card content is numeric" do
      it "render progress bar" do
        value = "3.14159265"
        numeric_card = create "I am a number", content: "3.14159265"
        html = numeric_card.format.render_progress_bar
        expect(html).to have_tag("div", with: { class: "progress" }) do
          with_tag "div", with: { class: "progress-bar",
                                  "aria-valuenow" => value },
                          text: /#{value}%/
        end
      end
    end
    context "card content is not numeric" do
      it "returns error message" do
        non_numeric_card = Card.create! name: "I am not a number", content: "There are 2 hard problems in computer science: cache invalidation, naming things, and off-by-1 errors."
        html = non_numeric_card.format.render_progress_bar
        expect(html).to eq("Only card with numeric content can be shown as progress bar.")
      end
    end
  end
end
