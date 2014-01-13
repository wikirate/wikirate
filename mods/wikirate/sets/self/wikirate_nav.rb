#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# WIKIRATE-NAV
# top drill-down navigation on Market and Company cards and their children

format :html do  
  view :core, :self=>:wikirate_nav do |args|
    if main = root.card                                                       and
      base = main.simple? ? main : Card[ '_1'.to_name.to_absolute main.name ] and
      base_type = base.type_name                                              and 
      %w{ Market Company }.member? base_type

      topics = main.simple? ? [] : begin
        if part2 = Card[ '_2'.to_name.to_absolute main.name ] and part2.type_name == 'Topic'
          topics_lineage(part2.name)
        end
      end

      if topics        
        links = [ [ base.name, nil, base_type ] ]
        topics.each { |topic| links << [topic, "#{base.name}+#{topic}", 'Topic', ] }

        %{
          <div id="wikirate-nav">
          #{
            links.map do |text, title, type|
              link_to_page text, title, :navType=>type
            end * "<span>&raquo;</span>"
          }
          </div>
        }
      else '' end

    else '' end
  end

  def topics_lineage topic
    child = [ topic ]
    c = Card.search :type=>'Topic', :right_plus=>['subtopic', {:refer_to=>topic} ], :return=>'name'
    ancestors = c.empty? ? [] : topics_lineage( c[0] )
    ancestors + child
  end
  
end

