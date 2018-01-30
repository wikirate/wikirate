def generate_pdf
  puts "generating pdf"
  kit = PDFKit.new url, "load-error-handling" => "ignore"
  Dir::Tmpname.create(["source", ".pdf"]) do |path|
    kit.to_file(path)
    file_card.update_attributes!(file: ::File.open(path)) if ::File.exist?(path)
  end
rescue => e
  Rails.logger.info "failed to convert source page to pdf #{e.message}"
end

def html_link?
  file_type.present? && file_type.start_with?("text/html")
end
