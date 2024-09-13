require File.expand_path "../../../config/environment", __FILE__
require "colorize"

user = Rails.env.development? ? "Joe Admin" : "Ethan McCutchen"
Card::Auth.signin user

FRAMEWORKS = {
  CHRB: "Corporate Human Rights Benchmark Topics",
  CWC: "Committee on Workers' Capital",
  DJSI: "Dow Jones Sustainability World Index",
  EO: "EO",
  ETI: "ETI",
  EUKI: "European Climate Initiative",
  G4: "Global Reporting Initiative Guidelines (4th Generation)",
  GRI: "Global Reporting Initiative Topics",
  ILO: "International Labor Organization",
  ISO: "International Organization for Standards (ISO)",
  KTC: "KTC",
  "Minerals Guidance": "OECD Minerals Guidance Steps",
  OECD: "Organization for Economic Cooperation and Development",
  PF: "PF",
  UNGC: "UN Global Compact Topics",
  PRI: "PRI",
  SDG: "UN Sustainable Development Goals Topics",
  UNDHR: "Universal Declaration of Human Rights",
  UNGPRF: "UN Guiding Principles Reporting Framework",
  UNGP: "UN Guiding Principles",
  WBA: "World Benchmarking Alliance Topics"
}.freeze

FALSES = ["Privacy", "Grievance"].freeze

def update_ungc_principle_topic_names
  Card.search type: :topic, complete: "Principle" do |topic|
    topic.update! name: "UNGC #{topic.name}"
  end
end

def add_topics_to_framework prefix, framework
  Card.search type: :topic, complete: prefix do |topic|
    next if topic.name.in?(FALSES) || topic.topic_framework.present?
    puts "adding #{topic.name} to #{framework}"
    topic.topic_framework_card.update! content: framework
  end
end

def add_topic_frameworks
  FRAMEWORKS.each do |prefix, name|
    puts "creating framework #{name}"
    Card.create! name: name, type: :topic_framework
    add_topics_to_framework prefix, name
  end
end

def add_default_framework
  name = "Wikirate ESG Topics"
  Card.search type: :topic, not: { right_plus: :topic_framework } do |topic|
    topic.topic_framework_card.update! content: name
  end
end

update_ungc_principle_topic_names
add_topic_frameworks
add_default_framework
