

attr_accessor :variant

# contribution type card  optimize?
def cont_type_card
  @cont_type_card ||= Card.fetch cardname.left_name.right
end

def user_card
  @user_type_card ||= Card.fetch cardname.left_name.left
end

def raw_content
  cont_type_card.send "#{variant}_report_content", user_card.id
end

format :html do
  view :core do
    card.variant = voo.structure if voo.structure
    super()
  end
end
