format :html do
  view :editor do |args|
    if (year = Card.fetch(card.cardname.left_name.tag)) && year.type_id == Card::YearID
      super(args)
    else
      with_inclusion_mode :normal do
        %{
          <div class="source-editor nodblclick">
            #{ form.hidden_field :content, :class=>'card-content' }
            <div class="sourcebox">
              #{ text_field_tag :sourcebox, nil, :placeholder=>'http://' }
              #{ button_tag 'Add' }
            </div>
            #{ _render_core args }
          </div>
        }
      end
    end
  end
  
  
end

