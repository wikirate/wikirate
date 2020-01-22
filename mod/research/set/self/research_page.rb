include_set Abstract::Media

format :html do
  def layout_name_from_rule
    :wikirate_two_column_layout
  end

  view :open do
    render_slot_machine
  end

  view :edit, cache: :never, wrap: :none do
    @answer_view = :research_edit_form
    render_slot_machine
  end

  view :content, cache: :never do
    _render_core
  end

  view :add_relation, cache: :never do
    @answer_view = :research_form
    @answer_card = Card.new name: [metric, company, year.to_s],
                            type_id: Card::RelationshipAnswerID
    @answer_card.define_singleton_method(:unknown?) { true }
    slot_machine
  end

  view :core do
    render_slot_machine
  end

  view :slot_machine, perms: :create, wrap: :slot do
    haml :slot_machine
  end

  def slot_machine opts={}
    %i[metric company related_company project year active_tab].each do |n|
      instance_variable_set "@#{n}", opts[n] if opts[n]
    end
    _render_slot_machine
  end
end
