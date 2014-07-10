format :html do
  view :editor do |args|
    with_inclusion_mode :normal do
      %{
        <div class="sourcebox">
          #{ text_field_tag :sourcebox, nil, :placeholder=>'http://' }
          #{ button_tag 'Add' }
        </div>
        #{ _render_content args }
        #{ form_for_multi.hidden_field :content }
      }
    end
  end
end