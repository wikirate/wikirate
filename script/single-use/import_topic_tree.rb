require File.expand_path "../../../config/environment", __FILE__
require "colorize"

user = Rails.env.development? ? "Joe Admin" : "Ethan McCutchen"
Card::Auth.signin user

CSVFILE = File.expand_path "data/2025-02-27-topics.csv", __dir__
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
  args = {
    name: topicname,
    type: :topic,
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

import_topic_tree
