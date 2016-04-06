format :html do
  view :editor do |args|
    text_area :comment, rows: 3
  end
  view :comment_box,
       denial: :blank, tags: :unknown_ok,
       perms: ->(r) { r.card.ok? :comment } do |_args|
    <<-HTML
      <div class="comment-box nodblclick">#{comment_form}</div>
    HTML
  end
end
