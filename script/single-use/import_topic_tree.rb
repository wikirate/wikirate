require File.expand_path "../../script_helper.rb", __FILE__

if ARGV.size < 1
  puts "Usage: ruby ./script/single-use/import_topic_tree DATA_FILE_NAME"
  exit
end

CSVFILE = File.expand_path "data/#{ARGV[0]}", __dir__
# expects title row
# each data row contains framework and two levels of topics
# see data dir for examples


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
  topics_tree.each do |framework, h1|
    ensure_framework framework
    h1.each do |t1, h2|
      ensure_topic framework, t1
      h2.each do |t2, _h3|
        ensure_topic framework, t2, t1
      end
    end
    ensure_framework_categories framework, h1.keys
  end
end

def ensure_topic framework, topicname, category=nil
  puts "ensuring #{topicname}"
  args = {
    name: [framework, topicname].cardname,
    type: :topic,
    conflict: :override,
  }
  args[:fields] = { category: [framework, category].cardname } if category.present?
  Card.ensure! args
end

def ensure_framework framework
  if (framework_card = framework.card)
    return if framework_card.type_code == :topic_framework
    fail "Framework name is taken by non framework card"
  else
    create_framework framework
  end
end

def create_framework framework
  Card.ensure! type: :topic_framework,
               name: framework,
               conflict: :override
end

def ensure_framework_categories framework, categories
  category_names = categories.map { |title| [framework, title].cardname }

  Card.ensure! name: [framework, :category].cardname,
               content: category_names,
               conflict: :override
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

puts_topics_tree
import_topic_tree
