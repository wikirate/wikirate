require "decko/mods_spec_helper"
require_relative "source_helper"

Spork.prefork do
  RSpec.configure do |config|
    config.include RSpecHtmlMatchers
    config.before(:each) do
      Card::Env[:protocol] = "http://"
      Card::Env[:host] = "wikirate.org"
    end
    config.example_status_persistence_file_path = "spec/examples.txt"
  end
end

include SourceHelper
include SharedData::Samples

def create_answer args
  with_user(args[:user] || "Joe User") do
    Card.create answer_args(args)
  end
end

def build_answer args
  Card.new answer_args(args)
end

def answer_args(metric: sample_metric.name,
                company: sample_company.name,
                year: "2015",
                value: "sample value",
                source: sample_source.name)
  { type_id: Card::MetricAnswerID,
    "+metric" => metric,
    "+company" => company,
    "+value" => value,
    "+year" => year,
    "+source" => source
  }
end

# Usage:
# create_metric type: :researched do
#   Siemens 2015: 4, 2014: 3
#   Apple   2105: 7
# end
def create_metric opts={}, &block
  Card::Auth.as_bot do
    if opts[:name] && opts[:name].to_name.parts.size == 1
      opts[:name] = "#{Card::Auth.current.name}+#{opts[:name]}"
    end
    opts[:name] ||= "TestDesigner+TestMetric"
    Card::Metric.create opts, &block
  end
end

def have_badge_count num, klass, label
  have_tag "span.#{klass}" do
    with_tag "span.badge", text: /#{num}/
    with_tag "label", text: /#{label}/
  end
end

def html_trim str
  s = str.dup
  s.delete!("\r\n")
  s.delete!("\n")
  s.delete!("  ")
  s
end
