def virtual?
  true
end

def sections
  @sections ||= begin
    if left.present?
      user_card = left
      [{ name: Card[:metric].name, contributions: :contributed_metrics },
       { name: Card[:claim].name, contributions: :contributed_claims },
       { name: Card[:source].name, contributions: :contributed_sources },
       { name: Card[:overview].name,
         contributions: :contributed_analysis
       },
       { name: Card[:project].name, contributions: :contributed_campaigns }
      ].map do |args|
        c_card = user_card.fetch(trait: args[:contributions])
        count = c_card && c_card.contribution_count
        contr_name = c_card && c_card.cardname.url_key
        [(count || 0), args[:name], contr_name]
      end
    end
  end
end

format :html do
  view :core do |_args|
    if card.sections
      card.sections.sort.reverse.map do |_count, name, contr_name|
        section_args = { view: :open, title: name, hide: "menu" }
        # FIXME: - cardname
        if name == "Initiative"
          section_args[:items] =
            { view: :content, structure: "initiative item" }
        end
        nest Card.fetch(contr_name), section_args
      end.join "\n"
    else
      ""
    end
  end

  view :header do |args|
    %(
      <div class="card-header #{args[:header_class]}">
        <div class="card-header-title #{args[:title_class]}">
          #{_optional_render :toggle, args, :hide}
          #{_optional_render :title, args}
          #{_optional_render :contribution_counts, args}
        </div>
      </div>
      #{_optional_render :toolbar, args, :hide}
    )
  end

  view :contribution_counts do |_args|
    content_tag :div, class: "counts" do
      if card.sections
        card.sections.map do |count, name, contr_name|
          content_tag :a, class: "item", href: "##{contr_name}" do
            %(
              <span class="#{name.downcase}">#{count}</span>
              <p class="legend">#{name}</p>
            ).html_safe
          end
        end.join("\n")
      else
        ""
      end
    end
  end
end
