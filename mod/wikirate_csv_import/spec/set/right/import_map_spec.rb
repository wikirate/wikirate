RSpec.describe Card::Set::Right::ImportMap do
  def card_subject
    @card_subject ||= Card["answer import test"].import_map_card
  end

  check_views_for_errors :core, :bar

  describe "#map" do
    it "contains a key for each mapped column" do
      expect(card_subject.map.keys).to eq(AnswerImportItem.mapped_column_keys)
    end

    it "maps existing names to ids" do
      name = "Jedi+disturbances in the Force".to_name
      expect(card_subject.map[:metric][name]).to eq(name.card_id)
    end

    it "maps non-existing names to nil" do
      expect(card_subject.map[:metric])
        .to include("Not a metric" => nil)
    end

    it "handles blank content" do
      card_subject.content = ""
      expect(card_subject.map).to be_a(Hash)
    end
  end

  describe "#auto_map!" do
    it "creates a map based on auto matching" do
      initial_content = card_subject.content
      puts initial_content
      puts card_subject.auto_map!
      expect(card_subject.auto_map!).to eq(initial_content)
    end
  end

  describe "event: update_import_mapping" do
    it "updates map based on 'mapping' parameter" do
      update_with_mapping_param wikirate_company: { "Google" => "Google LLC" } do |card|
        expect(card.map[:wikirate_company]["Google"])
          .to eq("Google LLC".to_name.card_id)
      end
    end

    it "raises error if mapping is not a card" do
      update_with_mapping_param metric: { "Not a metric" => "Not a card" } do |card|
        expect(card.errors[:content]).to include(/invalid metric mapping/)
      end
    end

    it "raises error if mapping has the wrong type" do
      update_with_mapping_param metric: { "Not a metric" => "Google LLC" } do |card|
        expect(card.errors[:content]).to include(/invalid metric mapping/)
      end
    end
  end

  describe "event: update_import_status" do
    it "moves newly valid items to 'ready'" do
      update_with_mapping_param source_mapping(1) do |card|
        status_card = card.left.import_status_card
        expect(status_card.status.item_hash(0)[:status]).to eq(:ready)
      end
    end

    it "keeps badly mapped items in 'not ready'" do
      update_with_mapping_param(source_mapping(1, "not a source")) do |card|
        status_card = card.left.import_status_card
        expect(status_card.status.item_hash(4)[:status]).to eq(:not_ready)
      end
    end
  end

  describe "HtmlFormat#tab_title" do
    it "gives counts for total and unmapped values" do
      expect(format_subject.tab_title(:metric))
        .to have_tag("div.tab-title") do
          with_tag "span.count-number" do
            with_tag "div.tab-badge" do
              with_tag("span.badge") { 2 }
              with_tag "span.badge-label" do
                with_tag "i.fa-bar-chart"
              end
            end
          end
          with_tag "span.count-label" do
            "(1) Metrics"
          end
        end
    end
  end

  describe "CsvFormat view: export" do
    it "exports mappings for a given type" do
      Card::Env.params[:map_type] = "metric"
      jd = "Jedi+disturbances in the Force".to_name
      csv = "Name in File,Name in WikiRate,WikiRate ID\n" \
            "#{jd},#{jd},#{jd.card_id}\n" \
            "Not a metric,,\n"
      expect(card_subject.format(:csv).render_export).to eq(csv)
    end
  end
end

def update_with_mapping_param value
  with_mapping_param value do
    card_subject.update({})
    yield card_subject
  end
end

def with_mapping_param value
  Card::Env.params[:mapping] = value
  yield
end

def source_mapping q, target=":darth_vader_source"
  { source: { "http://google.com/search?q=#{q}" => target } }
end

# TODO: cypress tests for update mapping
