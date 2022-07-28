# TODO: abstract and move to card-mod-csv_import

RSpec.describe Card::Set::Right::ImportMap do
  def card_subject
    @card_subject ||= Card["answer import test"].import_map_card
  end

  check_html_views_for_errors

  describe "HtmlFormat" do
    describe "#map_ui" do
      it "escapes square brackets" do
        expect(format_subject.map_table(:wikirate_company))
          .to have_tag("input._import-mapping", with: {
                         name: "mapping[wikirate_company][Google]",
                         form: "mappingForm"
                       })
      end

      it "escapes spaces correctly" do
        expect(format_subject.map_table(:wikirate_company))
          .to have_tag("input._import-mapping", with: {
                         name: "mapping[wikirate_company][New+Company]"
                       })
      end
    end

    describe "#suggest_link" do
      it "produces links for supported types" do
        expect(format_subject.suggest_link(:wikirate_company, "Goog"))
          .to match(Regexp.new(Regexp.escape("/Company")))
      end

      it "supports custom filter keys" do
        expect(format_subject.suggest_link(:source, "http://woot.com"))
          .to match(Regexp.new(Regexp.escape(CGI.escape("filter[wikirate_link]"))))
      end
    end
  end

  describe "#map" do
    it "contains a key for each mapped column" do
      expect(card_subject.map.keys).to eq(Card::AnswerImportItem.mapped_column_keys)
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
      expect(card_subject.auto_map!).to eq(initial_content)
    end

    it "handles values with separators" do
      card_subject.auto_map!
      expect(card_subject.map[:source].keys)
        .to include("https://thereaderwiki.com/en/Space_opera")
    end
  end

  describe "event: update_import_mapping" do
    it "updates map based on 'mapping' parameter" do
      card = update_with_mapping_param wikirate_company: { "Google" => "Google LLC" }
      expect(card.map[:wikirate_company]["Google"]).to eq("Google LLC".card_id)
    end

    it "catches error if mapping is not a card" do
      card = update_with_mapping_param metric: { "Not a metric" => "Not a card" }
      expect(card.errors[:content]).to include(/invalid metric mapping/)
    end

    it "catches error if mapping has the wrong type" do
      card = update_with_mapping_param metric: { "Not a metric" => "Google LLC" }
      expect(card.errors[:content]).to include(/invalid metric mapping/)
    end

    it "catches error if data types are wonky" do
      card = update_with_mapping_param metric: { "Not a metric" => { wtf: "really!?" } }
      expect(card.errors[:content]).to include(/invalid metric mapping/)
    end

    it "catches non unique keys in auto add" do
      card = update_with_mapping_param wikirate_company: { "A" => "AutoAdd" }
      expect(card.refresh(true).map[:wikirate_company]["A"]).to eq("AutoAddFailure")
    end

    it "auto adds", as_bot: true do
      card = update_with_mapping_param(
        wikirate_company: { "New Company" => "AutoAdd" },
        source: { "http://google.com/search?q=4" => "AutoAdd" }
      )
      expect(card.import_status_card.status.item_hash(3)[:status]).to eq(:ready)
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
          with_tag "span.tab-badge" do
            with_tag "span.badge-label" do
              "(1) Metrics"
            end
            with_tag("span.badge-count") { 2 }
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

  describe "#mapping_from_param" do
    it "unescapes escaped keys" do
      with_mapping_param metric: { "A+B" => "C" } do
        expect((card_subject.send :mapping_from_param)[:metric]["A B"]).to eq("C")
      end
    end
  end
end

def with_mapping_param value
  Card::Env.with_params(mapping: value) { yield }
end

def update_with_mapping_param value
  with_mapping_param(value) do
    card_subject.update({})
  end
  card_subject
end

def source_mapping q, target=":darth_vader_source"
  { source: { "http://google.com/search?q=#{q}" => target } }
end

# TODO: cypress tests for update mapping
