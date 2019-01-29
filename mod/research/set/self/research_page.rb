include_set Abstract::Media

format :html do
  view :open, cache: :never do
    voo.hide :menu
    super()
  end

  view :edit, cache: :never do
    @answer_view = :research_edit_form
    render_slot_machine
  end

  view :content, cache: :never do
    _render_core
  end

  view :add_relation, cache: :never do
    @answer_view = :research_form
    @answer_card = Card.new name: [metric, company, year.to_s],
                            type_id: RelationshipAnswerID
    @answer_card.define_singleton_method(:unknown?) { true }
    slot_machine
  end

  view :core, cache: :never do
    render_slot_machine
  end

  view :slot_machine, cache: :never, perms: :create do
    slot_machine
  end

  def slot_machine opts={}
    %i[metric company related_company project year active_tab].each do |n|
      instance_variable_set "@#{n}", opts[n] if opts[n]
    end
    wrap do
      haml :slot_machine
    end
  end
end
