format :html do
  view :editor do |args|
    with_inclusion_mode :normal do
      %{
        #{ form.hidden_field :content, :class=>'card-content' }
        <div class="sourcebox">
          #{ text_field_tag :sourcebox, nil, :placeholder=>'http://' }
          #{ button_tag 'Add' }
        </div>
        #{ _render_core args }
      }
    end
  end
end