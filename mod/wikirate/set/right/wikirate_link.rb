require "link_thumbnailer"

view :editor do
  form.text_field :content, class: "card-content form-control",
                            placeholder: "http://example.com"
end

event :validate_content, :validate, on: :save do
  begin
    @host = nil
    @host = URI(content).host
  rescue
    errors.add :link, "invalid uri #{content}" unless @host
  end
end

# event :block_url_changing, :validate, on: :update, changed: :content,
#                                       when: :prior_present? do
#   errors.add :link, "is not allowed to be changed."
# end
#
# def prior_present?
#   !db_content_was.empty?
# end
