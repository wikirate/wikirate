include_set Abstract::HamlFile

format :html do
  def edit_fields
    [:description]
  end

  def tabpanel
    tabs = [[:answer, "Metric Answer"],
            [:source, "Sources"],
            [:relationship_answer, "Relationship Answers"]]
    tab_args = tabs.each_with_object({}) do |(key, title), h|
      h[title] = tab_content key
    end
    static_tabs tab_args, "Metric Answer", :pills
  end

  def tab_content key
    codename = "#{key}_import_file".to_sym
    output [
      "<h5 class='mt-3'>New import file</h5>",
      nest(Card.new(type: codename),
         view: :new, hide: [:header, :menu, :new_type_formgroup]),
      "<h5 class='mt-3'>Recent imports</h5>",
      list_group(recent_imports(codename))
    ]
  end

  def recent_imports type
    type_id = Card.fetch_id type
    cards = Card.search left: { type_id: type_id }, right: { codename: "import_status" }, limit: 20,
                        sort: "update"

    cards.map do |item|
      nest item, view: :compact
    end
  end
end
