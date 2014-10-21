
format :html do
  view :better_about ,:perms=>:none do |args|
    editor_card = Card.fetch card.name+"+*editor"
    %{
      <div class="page-heading">
        <h1>About</h1>
        <div class="edits-by">
          <div class='subtitle-header'>Edits by</div>
          #{editor_card.format.render_shorter_search_result :item=>:link}
        </div>
      </div>
      #{card.format.render_content :home_view=>"content"}
    }    
  end
end  
