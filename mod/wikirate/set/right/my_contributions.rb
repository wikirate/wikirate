def virtual?
  true
end

def sections
  @sections ||= begin
    user_card = left
    [ {:name=>'Metrics',  :contributions => :contributed_metrics},
      {:name=>'Claims',   :contributions => :contributed_claims},
      {:name=>'Sources',  :contributions => :contributed_sources},
      {:name=>'Articles', :contributions => :contributed_analysis},
      {:name=>'Campaigns',:contributions => :contributed_campaigns}
    ].map do |args|
      c_card     = user_card.fetch(:trait=>args[:contributions])
      count      = c_card && c_card.contribution_count
      contr_name = c_card && c_card.cardname.url_key
      [ (count || 0), args[:name], contr_name ]
    end
  end
end


format :html do
  view :core do |args|
    card.sections.sort.reverse.map do |count, name, contr_name|
      section_args = {:view=>:open, :title=>name, :hide=>'menu'}
      if name == 'Campaigns'
        nest Card.fetch(contr_name), section_args.merge(:item=>{:view=>:content, :structure=>'campaign item'})
      else
        nest Card.fetch(contr_name), section_args
      end
    end.join "\n"
  end

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
    campaign_count = card.sections.last[0]
    content_tag :div, :class=>'counts' do
      card.sections.map do |count, name, contr_name|
        content_tag :a, :class=>"item", :href=>"##{contr_name}" do
          %{
            <span class="#{name.downcase}">#{count}</span>
            <p class="legend">#{name}</p>
          }.html_safe
        end
      end.join("\n")
    end
  end
end
