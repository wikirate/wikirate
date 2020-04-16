RSpec.describe Card::Set::Right::ImportStatus do
  let :status_counts do
    {
      not_ready: 12,
      ready: 1,
      failed: 2,
      importing: 0,
      success: 0, # overridden + imported
      total: 15
    }
  end

  def card_subject
    Card["answer_import_test"].import_status_card
  end

  describe "#content_hash" do
    it "parses json content" do
      card_subject.content = '{ "foo": "bar" }'
      expect(card_subject.content_hash["foo"]).to eq("bar")
    end
  end

  describe "#status" do
    it "contains counts for each column" do
      expect(card_subject.status[:counts]).to eq(status_counts)
    end

    it "contains an items for each import item" do
      expect(card_subject.status[:items])
        .to include([:not_ready,nil, { errors: ["unmapped source"] }])
    end

    it "handles manually set statuses" do
      card = Card.new name: "test+import status",
                      content: { counts: { total: 3 } }.to_json
      expect(card.status[:counts]).to eq total: 3
    end
  end

  describe "#generate!" do
    it "generates a fresh status hash based on mappings/validations alone" do
      initial_content_hash = card_subject.content_hash
      card_subject.generate!
      expect(card_subject.content_hash).to eq(initial_content_hash)
    end
  end

  describe "view: progress_bar" do
    def progress_section binding, bg, status_key, label
      binding.with_tag("div.progress-bar.bg-#{bg}") do
        with_tag "span.progress-value" do
          "#{status_counts[status_key]} #{label}"
        end
      end
    end

    it "renders progress bar if counts in the content" do
      expect(format_subject.render_progress_bar)
        .to have_tag("div.progress") do
          progress_section self, "warning", :not_ready, "Not Ready"
          progress_section self, "info", :ready, "Ready"
          progress_section self, "danger", :failed, "Failure"
        end
    end
  end
end
