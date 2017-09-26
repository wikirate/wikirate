describe Card::Set::Right::ImportStatus do
  specify "#state" do
    card = Card.new name: "test+import status", content: "5/6/17"
    expect(card.import_counts).to eq imported: 5, failed: 6, total: 17
  end

  describe "view :content" do
    it "renders progress bar if counts in the content" do
      card = Card.new name: "test+import status", content: "5/6/17"
      expect(card.format(:html)._render_content)
        .to have_tag "div.card-slot._refresh-timer",
                     with: { "data-refresh-url" => "/test+import_status?view=content" } do
        with_tag "div.progress" do
          with_tag "div.progress-bar.bg-success.progress-bar-striped",
                   with: { style: "width: 29%" }
          with_tag "div.progress-bar.bg-danger.progress-bar-striped",
                   with: { style: "width: 35%" }
        end

      end
    end

    it "renders empty progress bar if no content" do
      card = Card.new name: "test+import status", content: ""
      expect(card.format(:html)._render_content)
        .to have_tag "div.card-slot._refresh-timer",
                     with: { "data-refresh-url" => "/test+import_status?view=content" } do
        with_tag "div.progress" do
          with_tag "div.progress-bar.bg-success.progress-bar-striped",
                   with: { style: "width: 0%" }
          with_tag "div.progress-bar.bg-danger.progress-bar-striped",
                   with: { style: "width: 0%" }
        end

      end
    end
  end
end
