#format :html do
#  
#  view :navdrop, :type=>:wikirate_analysis do |args|
#    anchor_name = card.cardname.trunk_name
#    topic_name = card.cardname.tag_name
#    index = params[:index].to_i - 1
#    items = topics_siblings( topic_name, index).map do |item|
#      klass = item.to_name.key == topic_name.key ? 'class="current-item"' : ''
#      %{<li #{klass}>#{ link_to_page item, "#{anchor_name}+#{item}" }</li>}
#    end.join "\n"
#    %{ <ul>#{items}</ul> }
#  end
#
#
#  def topics_siblings topic, index
#    wql = if index==0
#      { :not=> { :referred_to_by=> {:right=>'subtopic'} } }
#    else
#      { :referred_to_by=>
#        { :right=>'subtopic', 
#          :left=>
#          { :type=>'Topic',
#            :right_plus=>['subtopic', {:refer_to=>topic} ]
#          }
#        }
#      }
#    end
#
#    Card.search( { :type=>'Topic', :sort=>'name', :return=>'name' }.merge( wql ) )
#  end
#end