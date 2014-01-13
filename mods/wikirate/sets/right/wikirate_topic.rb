#~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# +TOPIC EDITOR
# jstree-based topics tree editor
#format :html do
#  view :editor do |args|
#    kids = {}
#    Card.search( :left=>{:type=>'Topic'}, :right=>'subtopic', :limit=>0, :sort=>:name ).each do |junc|
#      parent = junc.cardname.trunk_name.key
#      children = junc.item_names.map { |n| n.to_name.key }
#      kids[parent] = children        
#    end
#
#    roots = kids.keys.find_all {|k| ![kids.values].flatten.member? k }
#    initial_content = card.item_names.map { |n| 'wtt-' + n.to_name.safe_key } * '|'
#
#    %{
#      #{ form.hidden_field :content, :class=>'card-content' }
#      <span class="initial-content" style="display:none">#{initial_content}</span>        
#      <div class="wikirate-topic-tree">
#        #{ build_topic_tree roots, kids }
#      </div>
#    }
#  end
#
#  # support method for topic editor
#  def build_topic_tree nodes, flathash
#    items = nodes.map do |n|
#      card = Card[n]
#      %{
#        <li id="wtt-#{card.cardname.safe_key}">
#          #{link_to_page card.name }
#          #{
#            if kids = flathash[n]
#              build_topic_tree kids, flathash
#            end
#          }
#        </li>
#      }
#    end.join "\n"
#    %{<ul>#{items}</ul>}
#  end
#end