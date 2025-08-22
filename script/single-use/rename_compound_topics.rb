# -*- encoding : utf-8 -*-
require File.expand_path "../../script_helper.rb", __FILE__

def run
  %i[clean_up_frameworks
     convert_topic_lists_to_item_ids
     update_topics

    ].each do |action|
    puts "current action: #{action}".blue
    send action
  end
end

# get rid of old framework cards and topic framework field cards
def clean_up_frameworks
  Card.search type: :topic_framework do |framework|
    framework.delete! unless framework.codename.present? || framework.name == "GRI"
  end
  Card.search(right: :topic_framework).each(&:delete!)
end

# resaving will convert content to ids because those classes now contain
# the Abstract::ItemId class
def convert_topic_lists_to_item_ids
  Card.where("right_id in (?)", %i[topic category].map(&:card_id))
      .where("not REGEXP_LIKE(db_content, '^[\~0-9\n]*$')")
      .where(trash: false).find_each do |list|
    list.include_set_modules
    puts "converting: #{list.name}".green
    list.save!
  end
end

def update_topics
  Card.where(type_id: :topic.card_id, trash: false).find_each do |topic|
    topic.include_set_modules
    rename_topic topic if topic.name.simple?
  end
end

def rename_topic topic
  oldname = topic.name
  puts "renaming topic #{oldname}".green

  handling_name_conflicts oldname do
    topic.update! name: [:esg_topics, oldname].cardname,
                  skip: :update_referer_content
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

run
