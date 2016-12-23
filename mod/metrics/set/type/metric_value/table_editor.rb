format :html do
  view :table_form, cache: :never do
    voo.editor = :inline_nests
    card_form :create, "main-success" => "REDIRECT",
              class: "new-value-form" do
      output [
               new_view_hidden,
               new_view_type,
               _render_table_editor
             ]
    end
  end

  view :table_editor, cache: :never do |args|
    render_haml relevant_sources: _render_relevant_sources(args),
                cited_sources: _render_cited_sources do
      <<-HAML
%table
  %tr.editor
    %td.year
      = field_nest :year, hide: :title
    %td.value
      = field_nest :value, hide: :title
      %h5
        Choose Sources or
        %a.btn.btn-sm.btn-default._add_new_source{href: "#"}
          %small
            %span.icon.icon-wikirate-logo-o.fa-lg
            Add a new source
      = relevant_sources
      = cited_sources
      = field_nest :discussion, title: 'Comment'
  %tr.buttons
    %td{colspan: 2}
      = _render_new_buttons
      .card-notice
      HAML
    end
  end
end
