format :html do
  # def edit_args args
  #  args[:structure] = 'source+*type+*Structure'
  # end
  view :editor do |args|
    with_nest_mode :normal do
      args[:structure] = "metric value type edit structure"
      render_
      %(
        <div class="source-editor nodblclick">
          #{form.hidden_field :content, class: 'card-content'}
          <div class="sourcebox">
            #{text_field_tag :sourcebox, nil, placeholder: 'source name or http://'}
            #{button_tag 'Add'}
          </div>
          #{_render_core args}
        </div>
      )
    end
    # source = Card.new type_code: :source, name: 'new source'
    # subformat(source)._render_content_formgroup(hide: '',
    #                                               buttons: ''
    #                                              )
  end
end
