include_set Abstract::HamlFile

format :html do
  def tabpanel
    tabs = [[:answer, "Metric Answer"],
            [:source, "Sources"],
            [:relationship_answer, "Relationship Answers"]]
    tab_args = tabs.each_with_object({}) do |(key, title), h|
      h[title] = nest Card.new(type: "#{key}_import_file".to_sym),
                      view: :new, hide: [:header, :menu, :new_type_formgroup]
    end
    static_tabs tab_args, "Metric Answer", :pills
  end
end
