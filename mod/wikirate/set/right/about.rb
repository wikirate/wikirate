
format :html do
  view :better_about ,:perms=>:none do |args|
    editor_card = Card.fetch card.name+"+*editor"
    show_editor = editor_card.item_names.length>0
    %{
      
      <div class="page-heading">
        <h1>About</h1>
        <div class="edits-by">

          #{"<div class='subtitle-header'>Edits by</div>" if show_editor}
          #{editor_card.format.render_shorter_search_result :item=>:link if show_editor }
          
        </div>
      </div>
      #{card.format.render_content :home_view=>"content"}
    }    
  end
end  