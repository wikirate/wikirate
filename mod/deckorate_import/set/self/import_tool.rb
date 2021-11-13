include_set Abstract::HamlFile

format :html do
  def edit_fields
    [:description]
  end

  def tabpanel
    tabs = [[:answer, "Answer"],
            [:source, "Sources"],
            [:relationship, "Relationship"]]
    tab_args = tabs.each_with_object({}) do |(key, title), h|
      h[title] = tab_content key
    end
    tabs tab_args, "Metric Answer", tab_type: :pills
  end

  def tab_content key
    codename = "#{key}_import_file".to_sym
    output [
      "<h5 class='mt-3'>New import file</h5>",
      new_import_form(codename),
      "<h5 class='mt-5'>Recent imports</h5>",
      list_group(recent_imports_list(codename)),
      "<h5 class='mt-5'>All import files</h5>",
      list_group(import_file_cards(codename))
    ]
  end

  def new_import_form import_type
    if ok? :create
      nest(Card.new(type: import_type),
           view: :new, hide: [:header, :menu, :new_type_formgroup])
    else
      "You have to #{signin_link} to create new import files."
    end
  end

  def recent_imports_list import_type
    import_status_cards(import_type).map do |item|
      nest item, view: :compact
    end
  end

  def import_status_cards import_type, limit=20
    type_id = import_type.card_id
    Card.search left: { type_id: type_id }, right: { codename: "import_status" },
                limit: limit, sort: "update"
  end

  def import_file_cards import_type
    type_id = import_type.card_id
    Card.search(type_id: type_id, sort: "create").map do |item|
      nest item, view: :link
    end
  end
end
