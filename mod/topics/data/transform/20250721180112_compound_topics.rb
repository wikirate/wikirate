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
    return if (oldname = topic.name).compound?

    framepoint = topic.topic_framework_card
    return no_framework(oldname) unless (framework = framepoint.firstname).present?

    topic.update! name: [framework, oldname].cardname
    oldname.card.update! type: :topic_title
    framepoint.delete!
  end

  def no_framework oldname
    puts "No framework for #{oldname}".red
  end
end
