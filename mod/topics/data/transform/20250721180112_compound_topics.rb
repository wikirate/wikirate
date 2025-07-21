# -*- encoding : utf-8 -*-

class CompoundTopics < Cardio::Migration::Transform
  def up
    clean_up_frameworks
    Card.search type: :topic do |topic|
      update_topic topic
    end
  end

  def clean_up_frameworks
    Card.search(type: :topic_framework) do |framework|
      next if framework.codename.present? || framework.name == "GRI"

      framework.delete!
    end
  end

  def update_topic topic
    return if topic.name.compound?

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

    placeholder = Card.create! name: "#{oldname} - placeholder", type: :topic_title
    fieldname = action == :add ? placeholder.name : oldname

    @conflicts.each do |c|
      c.update! name: [c.name.left, fieldname].cardname
    end

    placeholder.delete!
  end

  def no_framework oldname
    puts "No framework for #{oldname}".red
  end
end
