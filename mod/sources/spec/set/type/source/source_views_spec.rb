# -*- encoding : utf-8 -*-

RSpec.describe Card::Set::Type::Source, "#views" do
  let(:csv_file) do
    path = File.expand_path("../test.csv", __FILE__)
    File.open(path)
  end

  let(:source) { sample_source }
  let(:source_url) { source.fetch(trait: :file).file.url }

  describe "download link" do
    context "with file source" do
      it "renders upload icon" do
        expect(source.format.download_link)
          .to have_tag("a.source-color", with: { href: source_url }, text: /Download/) do
                with_tag "i.fa-download"
              end
      end
    end

    context "with link source" do
      it "renders globe icon" do
        original_link = source.fetch(trait: :wikirate_link).content
        expect(source.format.original_link)
          .to have_tag("a.source-color", with: { href: original_link },
                                         text: /Original/) do
                with_tag "i.fa-external-link-square"
              end
      end
    end

    context "with text source" do
      it "renders pencil icon" do
        new_sourcepage = create_source "test text report"
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
