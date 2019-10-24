# require File.expand_path("../../config/environment",  __FILE__)

require_relative "../../config/environment"
require "pry"

METRIC_NAME = "Core+Headquarters Location".freeze
# METRIC_NAME = "Jedi+Sith Lord in Charge".freeze
ANSWER_YEAR = "2019".freeze

raise "metric not found" unless Card[METRIC_NAME]&.type_id == Card::MetricID

def create_hq_answer company, value
  Card.create! name: Card::Name[METRIC_NAME, company, ANSWER_YEAR],
               type_id: Card::MetricAnswerID,
               subfields: { value: { content: value } }
end

Card::Auth.as_bot do
  Card.where(right_id: Card::HeadquartersID).find_each do |hq|
    company = Card[hq.left_id]
    next unless company&.type_id == Card::WikirateCompanyID

    value = hq.db_content
    next unless value.present?

    create_hq_answer company.name, value
  end
end
