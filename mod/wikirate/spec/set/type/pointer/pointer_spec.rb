# -*- encoding : utf-8 -*-

RSpec.describe Card::Set::Type::Pointer::Export do
  describe "rendering json in export mode" do
    let(:elbert) do
      create "Elbert Hubbard",
             content: "Do not take life too seriously."
    end
    let(:elbert_punchline) do
      create "Elbert Hubbard+punchline",
             content: "You will never get out of it alive."
    end
    let(:elbert_quote) do
      create "Elbert Hubbard+quote",
             content: "Procrastination is the art of keeping up with yesterday."
    end
    let(:elbert_container) do
      create "elbert container",
             type_id: Card::PointerID,
             content: "[[#{elbert.name}]]"
    end

    def json_export args={}
      @json ||= begin
        args[:name] ||= "normal pointer"
        args[:type] ||= :pointer
        if args[:content].is_a?(Array)
          args[:content] = args[:content].to_pointer_content
        end
        Card::Auth.as_bot do
          collection_card = Card.create! args
          card = Card.create! name: "export card",
                              type_id: Card::PointerID,
                              content: "[[#{collection_card.name}]]"
          card.format(:json).render_export
        end
      end
    end

    context "pointer card" do
      it "contains cards in the pointer card and its children" do
        json_export type: :pointer, content: [elbert.name, elbert_punchline.name]

        expect(json_export)
          .to include(
            { name: "normal pointer",
              type: "Pointer",
              content: "[[Elbert Hubbard]]\n[[Elbert Hubbard+punchline]]" },
            { name: "Elbert Hubbard",
              type: "Basic",
              content: "Do not take life too seriously." },
            name: "Elbert Hubbard+punchline",
            type: "Basic",
            content: "You will never get out of it alive."
          )
      end

      it "handles multi level pointer cards" do
        json_export type: :pointer,
                    content: [elbert_container.name, elbert_punchline.name]

        expect(json_export)
          .to include(
            { name: "normal pointer",
              type: "Pointer",
              content: "[[elbert container]]\n[[Elbert Hubbard+punchline]]" },
            { name: "elbert container",
              type: "Pointer",
              content: "[[Elbert Hubbard]]" },
            { name: "Elbert Hubbard",
              type: "Basic",
              content: "Do not take life too seriously." },
            name: "Elbert Hubbard+punchline",
            type: "Basic",
            content: "You will never get out of it alive."
          )
      end

      it "stops if the depth count > 10" do
        json_export type: :pointer, name: "normal pointer", content: ["normal pointer"]
        expect(json_export).to include(name: "normal pointer", type: "Pointer",
                                       content: "[[normal pointer]]")
      end
    end

    context "Skin card" do
      it "contains cards in the pointer card and its children" do
        expect(json_export(type: :skin, content: [elbert.name]))
          .to include(
            { name: "normal pointer",
              type: "Skin",
              content: "[[Elbert Hubbard]]" },
            name: "Elbert Hubbard",
            type: "Basic",
            content: "Do not take life too seriously."
          )
      end
    end

    context "search card" do
      it "contains cards from search card and its children" do
        elbert
        elbert_punchline
        elbert_quote

        json_export(name: "search card", type: :search_type,
                    content: %({"left":"Elbert Hubbard"}))
        expect(json_export)
          .to include(
            { name: "search card",
              type: "Search",
              content: %({"left":"Elbert Hubbard"}) },
            { name: "Elbert Hubbard+punchline",
              type: "Basic",
              content: "You will never get out of it alive." },
            name: "Elbert Hubbard+quote",
            type: "Basic",
            content: "Procrastination is the art of keeping up with yesterday."
          )
      end
    end
  end
end
