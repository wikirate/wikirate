view :editor do |args|
  text_field :content, class: 'card-content', disabled: args[:disabled]
end