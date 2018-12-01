require "bundler"

PDFKit.configure do |config|
  config.default_options = {
    page_size: "A4",
    print_media_type: true
  }
  config.wkhtmltopdf = "#{Bundler.bundle_path}/bin/wkhtmltopdf"
end
