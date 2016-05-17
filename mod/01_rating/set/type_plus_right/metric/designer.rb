view :editor do |args|
  text_field :content, class: "card-content", readonly: args[:readonly]
end
