describe Card::Set::Type::SourceImportFile do
  let(:source_title) do
    "Apple Inc.-Corporate Social Responsibility Report-2013"
  end

  before do
    login_as "joe_user"
    test_csv = File.open "#{Rails.root}/mod/wikirate/spec/set/" \
                         "type/source_import_test.csv"
    @source_import_file = Card.create! name: "does it matter?",
                                       source_import_file: test_csv,
                                       type_id: Card::SourceImportFileID
    Card::Env.params["is_data_import"] = "true"
  end

  def test_row_content args, input_title
    with_tag "td", text: args[:file_company]
    if args[:wikirate_company].present?
      with_tag "td", text: args[:wikirate_company]
    end
    with_tag "td", text: args[:source]
    test_row_inputs args, input_title
  end

  def test_row_inputs args, input_title
    input_args = ["input", with: {
      type: "text", name: "corrected_company_name[#{args[:row]}]"
    }]
    title_input_args = ["input", with: {
      type: "text", name: "title[#{args[:row]}]", value: input_title
    }]
    with_tag(*title_input_args)
    with_tag(*input_args) if args[:status] != "exact"
  end

  def with_row checked, context, args
    input_title = args.delete :input_title
    with = { type: "checkbox", id: "import_data_", value: args.to_json }
    with[:checked] = "checked" if checked
    with_tag "tr[class=\"#{context}\"]" do
      with_tag "input", with: with
      test_row_content args, input_title
    end
  end

  def trigger_import data, title
    Card::Env.params[:import_data] = data
    Card::Env.params[:title] = title
    Card::Env.params["is_data_import"] = "true"
    @source_import_file.update_attributes! subcards: {}
    @source_import_file
  end

  def verify_subcard_content source, subcard_codename, expected, pointer=false
    subcard = source.fetch trait: subcard_codename
    if pointer
      expect(subcard.item_names).to include(expected)
    else
      expect(subcard.content).to eq(expected)
    end
  end

  describe "Import action" do
    context "correct info" do
      it "adds a correct source" do
        data = [{
          file_company: "Apple Inc", year: "2014",
          report_type: "Conflict Minerals Report",
          source: "http://placehold.it/100x100",
          title: nil, row: 1, wikirate_company: "Apple Inc", status: "exact",
          company: "Apple Inc"
        }]
        source_file = trigger_import data, "1" => source_title
        expect(source_file.subcards.empty?).to be_falsey
        source_card = source_file.subcards[source_file.subcards.to_a[0]]

        verify_subcard_content source_card, :wikirate_title, source_title
        verify_subcard_content source_card, :report_type,
                               "Conflict Minerals Report", true
        verify_subcard_content source_card, :wikirate_company,
                               "Apple Inc", true
        verify_subcard_content source_card, :year,
                               "2014", true
      end
    end

    context "existing sources" do
      context "with fields" do
        let(:samsung_data) do
          [{
            file_company: "Samsung", year: "2013",
            report_type: "Corporate Social Responsibility Report",
            source: "http://wagn.org",
            title: nil, row: 1, wikirate_company: "Samsung", status: "exact",
            company: "Samsung"
          }]
        end

        let(:title) do
          { "1" => "SiDan" }
        end

        before do
          @source_card =
            create_page url: "http://wagn.org",
                        subcards: { "+title" => "hTc",
                                    "+company" => "[[Apple Inc]]",
                                    "+report_type" => "[[Conflict Minerals Report]]",
                                    "+year" => "[[2014]]" }

          trigger_import samsung_data, title
        end

        it "won't update existing source title" do
          # to trigger a "clean" update
          trigger_import samsung_data, title
          @source_card.success.params.clear
          verify_subcard_content @source_card, :wikirate_title, "hTc"
          expect(@source_card.success.params).to be_empty
        end

        it "updates exisitng source" do
          expected_report_type = "Corporate Social Responsibility Report"
          expected_company = "Samsung"
          verify_subcard_content @source_card, :report_type,
                                 expected_report_type, true
          verify_subcard_content @source_card, :wikirate_company,
                                 expected_company, true
          verify_subcard_content @source_card, :year, "2013", true
          feedback = @source_import_file.success[:updated_sources]
          expect(feedback).to include(["1", @source_card.name])
        end
      end

      context "without title" do
        before do
          @url = "http://wagn.org"
          @source_card = create_link_source @url
          data = [{
            file_company: "Apple Inc", year: "2014",
            report_type: "Conflict Minerals Report",
            source: "http://wagn.org",
            title: nil, row: 1, wikirate_company: "Apple Inc", status: "exact",
            company: "Apple Inc"
          }]
          expected_title = "hTc"
          title = { "1" => expected_title }
          trigger_import data, title
        end

        it "updates existing source" do
          verify_subcard_content @source_card, :wikirate_title, "hTc"
          feedback = @source_import_file.success[:updated_sources]
          expect(feedback).to include(["1", @source_card.name])
        end

        it "renders correct feedback html" do
          Card::Env[:params] = @source_import_file.success.raw_params
          expect(@source_import_file.format.render_core).to(
            have_tag(:div, with: { class: "alert alert-warning" }) do
              with_tag :h4, text: "Existing sources updated"
              with_tag :ul do
                with_tag :li, text: "Row 1: #{@source_card.name}"
              end
            end
          )
        end
      end
    end

    context "duplicated sources in file" do
      before do
        @url = "http://example.com/12333214"
        data = [{
          file_company: "Apple Inc", year: "2014",
          report_type: "Conflict Minerals Report",
          source: @url,
          title: nil, row: 1, wikirate_company: "Apple Inc", status: "exact",
          company: "Apple Inc"
        }, {
          file_company: "Samsung", year: "2013",
          report_type: "Conflict Minerals Report",
          source: @url,
          title: nil, row: 2, wikirate_company: "Samsung", status: "exact",
          company: "Samsung"
        }]
        title = { "1" => source_title, "2" => "Si L Dan" }
        @source_file = trigger_import data, title
      end

      it "only adds the first source" do
        expect(@source_file.subcards.empty?).to be_falsy
        source_card = @source_file.subcards[@source_file.subcards.to_a[0]]

        verify_subcard_content source_card, :wikirate_title, source_title
        verify_subcard_content source_card, :report_type,
                               "Conflict Minerals Report", true
        verify_subcard_content source_card, :wikirate_company,
                               "Apple Inc", true
        verify_subcard_content source_card, :year,
                               "2014", true
        feedback = @source_file.success.params[:duplicated_sources]
        expect(feedback).to include(["2", @url])
      end

      it "renders correct feedback html" do
        Card::Env[:params] = @source_file.success.raw_params
        html = @source_file.format.render_core
        css_class = "alert alert-warning"
        expect(html).to have_tag(:div, with: { class: css_class }) do
          with_tag :h4, text: "Duplicated sources in import file."\
                              " Only the first one is used."
          with_tag :ul do
            with_tag :li, text: "Row 2: http://example.com/12333214"
          end
        end
      end
    end

    context "missing fields" do
      def sample_data
        [{
          file_company: "Apple Inc", year: "2014",
          source: "http://wagn.org",
          report_type: "Conflict Minerals Report",
          title: nil, row: 1, wikirate_company: "Apple Inc", status: "exact",
          company: "Apple Inc"
        }]
      end

      def sample_title
        { "1" => source_title }
      end

      it "misses source field" do
        data = sample_data
        data[0].delete :source
        source_file = trigger_import data, sample_title
        err_key = "import error (row 1)".to_sym
        err_msg = "source missing"
        expect(source_file.errors).to have_key(err_key)
        expect(source_file.errors[err_key]).to include(err_msg)
      end
      it "misses company field" do
        data = sample_data
        data[0].delete :company
        source_file = trigger_import data, sample_title
        err_key = "import error (row 1)".to_sym
        err_msg = "company missing"
        expect(source_file.errors).to have_key(err_key)
        expect(source_file.errors[err_key]).to include(err_msg)
      end
      it "misses report type field" do
        data = sample_data
        data[0].delete :report_type
        source_file = trigger_import data, sample_title
        err_key = "import error (row 1)".to_sym
        err_msg = "report_type missing"
        expect(source_file.errors).to have_key(err_key)
        expect(source_file.errors[err_key]).to include(err_msg)
      end
      it "misses year field" do
        data = sample_data
        data[0].delete :year
        source_file = trigger_import data, sample_title
        err_key = "import error (row 1)".to_sym
        err_msg = "year missing"
        expect(source_file.errors).to have_key(err_key)
        expect(source_file.errors[err_key]).to include(err_msg)
      end
    end
  end

  describe "import table" do
    subject { @source_import_file.format.render_import }

    it "shows correctly import table" do
      is_expected.to have_tag("table", with: { class: "import_table" }) do
        with_row true, "success",
                 file_company: "Apple Inc.",
                 year: "2013",
                 report_type: "Corporate Social Responsibility Report",
                 source: "http://example.com/1233213",
                 title: nil,
                 csv_row_index: 1,
                 wikirate_company: "Apple Inc.",
                 status: "exact",
                 company: "Apple Inc.",
                 input_title: source_title,
                 row: 2
        with_row true, "success",
                 file_company: "Apple Inc",
                 year: "2014",
                 report_type: "Conflict Minerals Report",
                 source: "http://example.com/12333214",
                 title: "hello world",
                 csv_row_index: 2,
                 wikirate_company: "Apple Inc",
                 status: "exact",
                 company: "Apple Inc",
                 input_title: "hello world",
                 row: 3
        with_row true, "warning",
                 file_company: "Apple",
                 year: "2012",
                 report_type: "Conflict Minerals Report",
                 source: "http://example.com/123332345",
                 title: "hello world1",
                 csv_row_index: 3,
                 wikirate_company: "Apple Inc.",
                 status: "partial",
                 company: "Apple Inc.",
                 input_title: "hello world1",
                 row: 1
      end
    end
  end
end
