format :html do
  view :core do |args|
    tabs = [
      ["topic", "Topics", "+topic+*cached count"],
      #["topic", "Projects", "+topic+*cached count"],
      ["overview", "Reviews", "+analyses with overview+*cached count"],
      ["metric", "Metrics", "+metric+*cached count"],
      ["note", "Notes", "+Note+*cached count"],
      ["reference", "Sources", "+sources+*cached count"]
    ]
    wikirate_layout "company", tabs, render_contribution_link(args)
  end

  view :topic_tab do |args|
    <<-HTML
      <div class="voting">
         {{_left+topic+upvotee search|drag_and_drop|content;structure:company topic drag item}}
         {{topic votee filter|core}}
         <div class="header-row">
           <div class="header-header">Topic</div>
            <div class="data-header">Contributions</div>
         </div>
        {{_left+topic+novotee search|drag_and_drop|content;structure:company topic drag item}}
        {{_left+topic+downvotee search|drag_and_drop|content;structure:company topic drag item}}
      </div>
    HTML
  end
end