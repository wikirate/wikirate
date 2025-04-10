require File.expand_path "../../../config/environment", __FILE__
require "colorize"

user = Rails.env.development? ? "Joe Admin" : "Ethan McCutchen"
Card::Auth.signin user

CSVFILE = File.expand_path "data/2025-04-10-topics.csv", __dir__
FRAMEWORK = "Wikirate ESG Topics"

def topics_tree
  rows.each_with_object({}) do |row, h|
    t1, t2, t3 = row.map(&:last)

    h[t1] ||= {}
    h[t1][t2] ||= {}
    h[t1][t2][t3] ||= {}
  end
end

def rows
  CSV.read CSVFILE, headers: true, header_converters: :symbol
end

def import_topic_tree
  topics_tree.each do |t1, h1|
    ensure_topic t1
    h1.each do |t2, h2|
      ensure_topic t2, t1
      h2.each do |t3, _h3|
        ensure_topic t3, t2
      end
    end
  end
end

def ensure_topic topicname, category=nil
  puts "ensuring #{topicname}"
  args = {
    name: topicname,
    type: :topic,
    conflict: :override,
    fields: { topic_framework: "Wikirate ESG Topics" }
  }
  args[:fields][:category] = category if category.present?
  Card.ensure! args
end

def puts_topics_tree
  topics_tree.each do |k1, v1|
    puts k1
    v1.each do |k2, v2|
      puts " - #{k2}"
      v2.each do |k3, _v3|
        puts "    - #{k3}"
      end
    end
  end
end

def delete_source_topic_taggings
  Card.search(left: { type: :source }, right: :topic).each &:delete!
end

def delete_all_topics
  Card.search type: :topic do |topic|
    delete_topic topic
  end
end

def delete_topic topic
  puts "deleting #{topic.name}".blue
  topic.delete!
rescue => e
  puts "failed to delete #{topic.name}: #{e.message}".red
end

delete_source_topic_taggings
delete_all_topics
puts_topics_tree
import_topic_tree
