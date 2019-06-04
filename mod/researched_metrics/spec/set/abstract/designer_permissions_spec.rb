# -*- encoding : utf-8 -*-

RSpec.describe Card::Set::Abstract::DesignerPermissions do
  METRIC_NAME = "Joe User+researched number 3".freeze
  ANSWER_NAME = "#{METRIC_NAME}+Samsung+2014".freeze

  RESTRICTED_METRIC_FIELDS = %i[value_type research_policy unit range value_options
                                report_type question about methodology].freeze
  RESTRICTED_ANSWER_FIELDS = %i[value source].freeze

  let(:metric) { Card[METRIC_NAME] }
  let(:answer) { Card[ANSWER_NAME] }

  def designer_can action, card
    Card::Auth.as "Joe User" do
      expect(card.ok?(action)).to be_truthy
    end
  end

  def nondesigner_cant action, card
    Card::Auth.as "Joe Camel" do
      expect(card.ok?(action)).to be_falsey
    end
  end

  %i[create update delete].each do |action|
    specify "designer can #{action} metric" do
      designer_can action, metric
    end

    specify "nondesigner cannot #{action} metric" do
      nondesigner_cant action, metric
    end

    specify "super user can #{action} metric", with_user: "Joe Admin"  do
      expect(metric.ok?(action)).to be_truthy
    end
  end

  describe "metric fields" do
    def metric_field_card name
      metric.fetch trait: name, new: {}
    end

    RESTRICTED_METRIC_FIELDS.each do |field|
      specify "designer can update metric field: #{field}" do
        designer_can :update, metric_field_card(field)
      end

      specify "nondesigner can't update metric field: #{field}" do
        nondesigner_cant :update, metric_field_card(field)
      end
    end
  end

  describe "answers" do
    %i[create update delete].each do |action|
      specify "designer can #{action} answer" do
        designer_can action, answer
      end

      specify "nondesigner cannot #{action} answer" do
        nondesigner_cant action, answer
      end
    end
  end

  describe "answer fields" do
    def answer_field_card name
      answer.fetch trait: name, new: {}
    end

    RESTRICTED_ANSWER_FIELDS.each do |field|
      specify "designer can update answer field: #{field}" do
        designer_can :update, answer_field_card(field)
      end

      specify "nondesigner can't update answer field: #{field}" do
        nondesigner_cant :update, answer_field_card(field)
      end
    end
  end
end
