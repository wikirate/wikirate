require File.expand_path "../../script_helper.rb", __FILE__

if ARGV.size < 2
  echo "Usage: ruby ./script/single-use/import_topic_tree FRAMEWORK DATA_FILE_NAME"
  exit
end

FRAMEWORK = ARGV[0]
CSVFILE = File.expand_path "data/#{ARGV[1]}", __dir__
# see data dir for examples
# expects title row and three levels of topics (should change that)


def topics_tree
  @topics_tree ||= rows.each_with_object({}) do |row, h|
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
    name: fullname(topicname),
    type: :topic,
    conflict: :override,
  }
  args[:fields] = { category: fullname(category) } if category.present?
  Card.ensure! args
end

def ensure_topic_framework
  Card.ensure! type: :topic_framework,
               name: FRAMEWORK,
               conflict: :override,
               fields:{
                 category: framework_categories
               }
end

def framework_categories
  topics_tree.keys.map { |title| fullname title }
end

def fullname title
  [FRAMEWORK, title].cardname
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

def delete_topic_taggings
  # %i[source metric dataset research_group rich_text yearly_value].each do |type|
  # Card.search left: { type: type }, right: :topic do |tagging|
  Card.search right: :topic do |tagging|
    delete_noisily tagging
  end
  # end
end

def delete_all_topics
  Card.search type: :topic do |topic|
    delete_noisily topic
  end
end

def delete_noisily card
  puts "deleting #{card.name}".blue
  card.delete!
rescue => e
  puts "failed to delete #{card.name}: #{e.message}".red
end

def change_type_of_metric_titles
  Card.search type: :topic, left_plus: [{}, { type: :metric }] do |topic|
    next if topic.codename

    topic.update! type: :metric_title
  end
end

# delete_topic_taggings
# change_type_of_metric_titles
# delete_all_topics
# Cardio::Utils.empty_trash
puts_topics_tree
ensure_topic_framework
import_topic_tree
