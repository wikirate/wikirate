format :html do
  view :header do |args|
    %{
      <div class="card-header #{ args[:header_class] }">
        <div class="card-header-title #{ args[:title_class] }">
          #{ _optional_render :toggle, args, :hide }
          #{ _optional_render :title, args }
          #{ _optional_render :contribution_counts, args }
        </div>
      </div>
      #{ _optional_render :toolbar, args, :hide}
      #{ _optional_render :edit_toolbar, args, :hide}
      #{ _optional_render :account_toolbar, args, :hide}
    }
  end

  view :contribution_counts do |args|
    user_id = card.left.id
    contribution_search_args = {
        :or=>{
          :created_by=>user_id,
          :edited_by=>user_id,
          :linked_to_by=>{:left=>user_id,:right=>["in","*upvotes","*downvotes"]}
        },
        :return=>:count
      }
    article_search_args =  {
        :right_plus=> [ 'article', {:or=>{:created_by=>user_id, :edited_by=>user_id }} ],
        :return=>:count
      }
    campaign_count = Card.search contribution_search_args.merge(:type=>'campaign')
    content_tag :div, :class=>'counts' do
      [ {:name=>'Metrics', :id=>MetricID},
        {:name=>'Claims',:id=>ClaimID},
        {:name=>'Sources', :id=>SourceID},
        {:name=>'Articles', :id=>WikirateAnalysisID, :query=>article_search_args}
      ].map do |args|
        inpage_link = "##{card.cardname.left_name.url_key}+"
        inpage_link += args[:name] == 'Articles' ? "analysis" : args[:name].downcase
        count = Card.search (args[:query] || contribution_search_args).merge(:type_id=>args[:id])
        content_tag :a, :class=>"item", :href=>inpage_link do
          %{
          <span class="#{args[:name].downcase}">#{count}</span>
          <p class="legend">#{args[:name]}</p>
          }.html_safe
        end
      end.join("\n")
    end.concat %{
        <a class="pull-right" href="##{card.cardname.left_name.url_key}+campaigns">
        <i class="fa fa-bullhorn"></i> #{campaign_count}
        </a>
      }.html_safe
  end
end
