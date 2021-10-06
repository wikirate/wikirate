# -*- encoding : utf-8 -*-

RSpec.describe Card::Set::Type::Source do
  def source_url url
    "#{Card::Env[:protocol]}#{Card::Env[:host]}/#{url}"
  end

  check_html_views_for_errors

  describe "while creating a Source" do
    before do
      login_as "joe_user"
    end

    xit "handles empty source" do
      expect { create_source "" }
        .to raise_error(ActiveRecord::RecordInvalid, /File required/)
    end

    it "creates website card with actions" do
      url = "http://www.google.com/?q=wikirate"
      sourcepage = create_source url
      website_card = sourcepage.fetch :wikirate_website
      expect(website_card.last_action).to be
    end

    example "without anything" do
      sourcepage = Card.new type_id: Card::SourceID
      expect(sourcepage).not_to be_valid
      # expect(sourcepage.errors).to have_key "File"
      # expect(sourcepage.errors["File"]).to include "required"
    end

    describe "with a file link" do
      context "when pointing to a file" do
        it "downloads it and saves as a file source" do
          pdf_url = "http://wikirate.s3.amazonaws.com/files/175839/12677809.pdf"
          # "http://wikirate.org/Page-000003962+File.pdf"
          sourcepage = create_source pdf_url
          expect(sourcepage.errors).to be_empty
          source_file = sourcepage.fetch(:file)
          expect(source_file).not_to be_nil
          # expect(sourcepage.fetch(:wikirate_link)).to be_nil
          expect(Card.exists?("#{sourcepage.name}+title")).to eq(false)
          expect(Card.exists?("#{sourcepage.name}+description")).to eq(false)
          expect(File.exist?(source_file.file.path)).to be true
        end

        it "handles this special url and saves as a file source" do
          pdf_url =
            "https://mozilla.github.io/pdf.js/web/compressed.tracemonkey-pldi-09.pdf"
            # I replaced the following url because it took 18min on semaphore to process
            # "https://www.unglobalcompact.org/system/attachments/9862/"\
            #        "original/Sinopec_2010_Sustainable_Development_Report.pdf?"\
            #        "1302508855"
          sourcepage = create_source pdf_url
          expect(sourcepage.errors).to be_empty
          expect(sourcepage.fetch(:file)).not_to be_nil
          # expect(sourcepage.fetch(:wikirate_link)).to be_nil
        end
        # FIXME: I don't entirely understand what the following is supposed to test,
        # but the url appears to be broken.  -efm
        xit "handles file behind cloudfront" do
          pdf_url = "https://www.angloamerican.com/~/media/Files/A/Anglo-"\
                    "American-PLC-V2/documents/aa-sdreport-2015.pdf"
          sourcepage = create_source pdf_url
          expect(sourcepage.errors).to be_empty
          expect(sourcepage.fetch(:file)).to be_instance_of(Card)
          expect(sourcepage.fetch(:wikirate_link).content).to eq(pdf_url)
        end
        context "when file is bigger than '*upload max'" do
          xit "won't create file source" do
            pdf_url = "http://cartographicperspectives.org/index.php/journal/"\
                      "article/download/cp49-issue/489"
            sourcepage = create_source pdf_url
            expect(sourcepage.errors).to be_empty
            expect(sourcepage.fetch(:wikirate_link)).not_to be_nil
            expect(sourcepage.fetch(:file)).to be_nil
            expect(Card["#{sourcepage.name}+title"]).to be_nil
            # FIXME: fails only on semaphore, don't know why -pk
            # expect(Card["#{sourcepage.name}+description"]).to be_nil
          end
        end
      end
    end
    describe "with a wikirate link" do
      xit "rejects existent card links" do
        expect_rejected_wikirate_source sample_company.name.url_key
      end
      xit "rejects non-existent card link" do
        expect_rejected_wikirate_source "not real wootitoot"
      end
    end
  end

  def expect_rejected_wikirate_source name
    source = new_source source_url(name)
    expect(source).to(
      be_invalid.because_of(
        "+File": include("download could not download file: 404 Not Found")
      ).and(
        be_invalid.because_of("+Link": include("Cannot use wikirate url as source"))
      )
    )
  end
end
