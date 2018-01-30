# -*- encoding : utf-8 -*-

RSpec.describe Card::Set::Type::Source, "views" do
  let(:csv_file) do
    path = File.expand_path("../test.csv", __FILE__)
    File.open(path)
  end

  before do
    login_as "joe_user"
    @url = "http://www.google.com/?q=wikirate"
    @source_page = create_page url: @url
  end

  it "metric_import_link" do
    sourcepage = create_source file: csv_file
    html = sourcepage.format.render_metric_import_link
    source_file = sourcepage.fetch trait: :file
    expected_url = "/#{source_file.name.url_key}?view=import"
    expect(html).to have_tag("a",
                             with: { href: expected_url },
                             text: "Import to metric values")
  end

  describe "original_icon_link" do

    context "file source" do
      it "renders upload icon" do
        sourcepage = create_source file: csv_file
        html = sourcepage.format.render_original_icon_link
        source_file = sourcepage.fetch trait: :file
        expect(html).to have_tag("a", with: { href: source_file.file.url }) do
          with_tag "i", with: { class: "fa fa-upload" }
        end
      end
    end

    context "link source" do
      it "renders globe icon" do
        html = @source_page.format.render_original_icon_link
        expect(html).to have_tag("a", with: { href: @url }) do
          with_tag "i", with: { class: "fa fa-globe" }
        end
      end
    end

    context "text source" do
      it "renders pencil icon" do
        new_sourcepage = create_source text: "test text report"
        html = new_sourcepage.format.render_original_icon_link
        text_source = new_sourcepage.fetch trait: :text
        expected_url = "/#{text_source.name.url_key}"
        expect(html).to have_tag("a", with: {
          href: expected_url
        }) do
          with_tag "i", with: { class: "fa fa-pencil" }
        end
      end
    end
  end
end
