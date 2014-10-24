format :html do
  
  view :titled_with_voting, :tags=>:comment do |args|
    wrap args do   
      [
        subformat( card.vote_count_card ).render_content,
        _render_header( args.reverse_merge :optional_menu=>:hide ),
        wrap_body( :content=>true ) { _render_core args },
        optional_render( :comment_box, args )
      ]
    end
  end
  
  view :header_with_voting do |args|
    render_haml({:args=>args.merge(:without_voting=>true)}) do
      %{
.header-with-vote
  .header-vote
    = subformat( card.vote_count_card ).render_details
  .header-title
    = render_header(args)
    .creator-credit
      = process_content "{{_self | structure:creator credit}}"
.clear-line
      }
    end
  end
end
