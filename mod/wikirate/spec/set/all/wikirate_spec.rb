
require File.expand_path("../../self/source_spec",  __FILE__)

RSpec.describe Card::Set::All::Wikirate do
  describe "while showing view" do
    it "renders edits_by view" do
      html = render_card :edits_by, name: sample_company.name
      expected =
        render_card_with_args(:shorter_search_result,
                              { name: "#{sample_company.name}+*editor" },
                              {}, items: { view: :link })
      expect(html).to include(expected)
    end

    it "renders titled_with_edits view" do
      card_name = sample_company.name
      html = render_card :titled_with_edits, name: card_name
      expect(html).to include(render_card(:header, name: card_name))
      expect(html).to include(render_card(:edits_by, name: card_name))
    end

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
      expect(html).to include("fa fa-pencil-square-o")
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

  describe "view of shorter_search_result" do
    let(:search_card_name) { "_search_test" }

    def create_dump_card number
      cards = []
      for i in 0..number - 1
        create "testcard#{i + 1}", type: "Basic"
        cards.push "\"testcard#{i + 1}\""
      end
      cards.join(",")
    end

    def create_search content
      create search_card_name, type: "search", content: content
    end

    it "handles only 1 result" do
      cards_name = create_dump_card 1
      search_card = create_search "{\"name\":#{cards_name}}"
      expected_content = search_card.item_cards(limit: 0)[0].format.render!(:link)
      html = render_card(:shorter_search_result, name: search_card_name)
      expect(html).to eq(expected_content)
    end
    it "handles only 2 results" do
      cards_name = create_dump_card 2
      search_card = create_search "{\"name\":[\"in\", #{cards_name}]}"
      result_cards = search_card.item_cards(limit: 0)
      expected_content = result_cards[0].format.render!(:link) + " and " + result_cards[1].format.render!(:link)
      html = render_card(:shorter_search_result, name: search_card_name)
      expect(html).to eq(expected_content)
    end
    it "handles only 3 results" do
      cards_name = create_dump_card 3
      search_card = create_search "{\"name\":[\"in\", #{cards_name}]}"
      result_cards = search_card.item_cards(limit: 0)
      expected_content = result_cards[0].format.render!(:link) + " , " + result_cards[1].format.render!(:link) + " and " + result_cards[2].format.render!(:link)
      html = render_card(:shorter_search_result, name: search_card_name)
      expect(html).to eq(expected_content)
    end
    it "handles more than 3 results" do
      cards_name = create_dump_card 10
      search_card = create_search "{\"name\":[\"in\", #{cards_name}]}"
      result_cards = search_card.item_cards(limit: 0)
      expected_content = result_cards[0].format.render!(:link) + " , " + result_cards[1].format.render!(:link) + " , " + result_cards[2].format.render!(:link)
      html = render_card(:shorter_search_result, name: search_card_name)
      expected =
        "#{expected_content} and <a class=\"known-card\" "\
        "href=\"#{search_card.format.render!(:url)}\"> 7 others</a>"
      expect(html).to eq(expected)
    end
  end
  describe "og_source view" do
    context "with existing card" do
      it "renders source view" do
        file_path = "#{Rails.root}/mod/wikirate/spec/set/all/DeathStar.jpg"
        dump_card = Card.create name: "dump is dump",
                                type_code: "image", image: File.new(file_path)
        expect(dump_card.format.render_og_source).to eq(dump_card.format.render_source)
      end
    end
    context "with nonexistent card" do
      it "renders the vertical logo link" do
        new_card = Card.new name: "oragne pen phone"
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

  describe "showcase_list view" do
    it "shows icons, type name and core view" do
      source_showcast =
        Card.fetch "joe_user+showcast sources",
                   new: { type_id: Card::PointerID }
      source_card = create_source "http://example.com"
      source_showcast << source_card
      source_showcast.save!

      html = source_showcast.format.render_showcase_list
      expect(html).to have_tag("i", with: { class: "fa fa-globe" })
      expect(html).to include("Sources")
      expect(html).to have_tag("div", with: { class: "pointer-list" }) do
        with_tag "div", with: { id: "#{source_card.name.safe_key}-closed-view" }
      end
    end
  end
end
