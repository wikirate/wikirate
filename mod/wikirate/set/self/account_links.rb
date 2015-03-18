format :html do

  view :raw do |args|
    #ENGLISH
    links = []
    klasses = ''
    if Auth.signed_in?
      klasses = 'logged-in'
      links << card_link( Auth.current.name, :id=>'my-card-link' )
      if Card.new(:type_id=>Card.default_accounted_type_id).ok? :create
        links << link_to( 'Invite', card_path('new/:signup'), :id=>'invite-a-friend-link' )
      end
      links << link_to( 'Log out', card_path('delete/:signin'), :id=>'signout-link' )
    else
      klasses = 'logged-out'
      if Card.new(:type_id=>Card::SignupID).ok? :create
        links << link_to( 'Join', card_path('new/:signup'), :id=>'signup-link', :class=>'btn btn-highlight' )
      end
      links << link_to( 'Log in', card_path(':signin'), :id=>'signin-link', :class=>'btn btn-default' )
    end

    %{<span id="logging" class="#{klasses}">#{ links.join ' ' }</span>}
  end

end
