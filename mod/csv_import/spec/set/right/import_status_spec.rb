RSpec.describe Card::Set::Right::ImportStatus do
  let(:status) do
    { counts: { imported: 5, failed: 6, total: 17 } }
  end

  specify "#state" do
    card = Card.new name: "test+import status", content: status.to_json
    expect(card.import_counts).to eq imported: 5, failed: 6, total: 17
  end

  describe "view :content" do
    def content_view content
      content = content.to_json if content.is_a? Hash
      card = Card.new name: "test+import status", content: content
      card.format(:html)._render_content
    end

    describe "progress bars" do
      let(:status) do
        { counts: { imported: 5, failed: 6, skipped: 4, total: 17 } }
      end

      it "renders progress bar if counts in the content" do
        expect(content_view(status))
          .to have_tag "div.card-slot._refresh-timer",
                       with: { "data-refresh-url" => "/test+import_status?view=content" } do
          with_tag "div.progress" do
            with_tag "div.progress-bar.bg-success.progress-bar-striped",
                     with: { style: "width: 29.41%" }
            with_tag "div.progress-bar.bg-danger.progress-bar-striped",
                     with: { style: "width: 35.29%" }
            with_tag "div.progress-bar.bg-info.progress-bar-striped",
                     with: { style: "width: 23.52%" }
          end
        end
      end

      it "renders progress bar if counts in the content" do
        expect(content_view(status))
          .to have_tag "div.card-slot._refresh-timer",
                       with: { "data-refresh-url" => "/test+import_status?view=content" } do
          with_tag "div.progress" do
            with_tag "div.progress-bar.bg-success.progress-bar-striped",
                     with: { style: "width: 29.41%" }
            with_tag "div.progress-bar.bg-danger.progress-bar-striped",
                     with: { style: "width: 35.29%" }
            with_tag "div.progress-bar.bg-info.progress-bar-striped",
                     with: { style: "width: 23.52%" }
          end
        end
      end

      it "hides empty parts in progress bar if no content" do
        expect(content_view(""))
          .to have_tag "div.card-slot",
                       with: { "data-refresh-url" => "/test+import_status?view=content" } do
          with_tag "div.progress" do
            without_tag "div.progress-bar.bg-success"
            without_tag "div.progress-bar.bg-danger"
          end
        end
      end
    end
    describe "progress reports" do
      let(:status) do
        { counts: { imported: 5, failed: 6, skipped: 4, total: 17 },
          imported: { 0 => "no 1", 2 => "no 3" },
          failed: { 1 => "no 2" },
          errors: { 1 => ["invalid name", "invalid value"] } }
      end

      it "renders list of imported entries" do
        expect(content_view(status))
          .to have_tag "div.alert.alert-success" do
          with_tag :ul do
            with_tag :li, text: "#1: no 1"
            with_tag :li, text: "#3: no 3"
          end
        end
      end

      it "renders list of errors" do
        expect(content_view(status)).to have_tag "div.alert.alert-danger" do
          with_tag :ul do
            with_tag :li, text: "#2: no 2 - invalid name; invalid value"
          end
        end
      end
    end
  end
end
