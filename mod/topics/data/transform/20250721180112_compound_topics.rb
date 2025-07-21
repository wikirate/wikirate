# -*- encoding : utf-8 -*-

class CompoundTopics < Cardio::Migration::Transform
  FIELDS_TO_UPDATE = %i[topic topic_framework category]

  def up
    clean_up_frameworks
    pausing_esg_families do
      # compoundify_framework_assignments
      Card.search type: :topic do |topic|
        update_topic topic
      end
      updating_field_cards
      update_clear_references
    end
  end

  def clean_up_frameworks
    Card.search(type: :topic_framework) do |framework|
      next if framework.codename.present? || framework.name == "GRI"

      framework.delete!
    end
  end

  def update_field_cards
    field_cards = Card.search right: { name: FIELDS_TO_UPDATE.clone.unshift(:in) }
    field_cards.each do |card|
      card.update! content: card.item_cards.map { |i| [:esg_topics, i].cardname }
    end
  end

  def pausing_esg_families
    cat = :esg_topics.card.category_card
    oldname = cat.name
    cat.update! name: "esg cat - placeholder"
    yield
    cat.update! name: oldname

  end

  # def compoundify_framework_assignments
  #   Card.search left: { type: :topic }, right: :topic_framework do |field|
  #     field.
  #   end
  # end

  def update_topic topic
    return if topic.name.compound?

    puts "updating topic #{topic.name}".green

    framepoint = topic.topic_framework_card
    return no_framework(oldname) unless (framework = framepoint.first_name).present?

    rename_topic topic, framework

    framepoint.delete!
  end

  def rename_topic topic, framework
    oldname = topic.name
    handling_name_conflicts oldname do
      topic.update! name: [framework, oldname].cardname
      oldname.card.update! type: :topic_title
    end
  end

  def handling_name_conflicts oldname
    @conflicts = Card.search right: oldname
    rename_conflicts oldname, :add
    yield
    rename_conflicts oldname, :delete
  end

  def rename_conflicts oldname, action
    return unless @conflicts.present?

    placeholder = Card.ensure! name: "#{oldname} - placeholder", type: :topic_title
    fieldname = action == :add ? placeholder.name : oldname

    @conflicts.each do |c|
      c.update! name: [c.name.left, fieldname].cardname
    end

    placeholder.delete! if action == :delete
  end

  def no_framework oldname
    puts "No framework for #{oldname}".red
  end
end
