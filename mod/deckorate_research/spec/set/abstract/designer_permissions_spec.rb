# -*- encoding : utf-8 -*-

RSpec.describe Card::Set::Abstract::StewardPermissions do
  let(:metric_name) { "Joe User+researched number 3" }
  let(:metric) { metric_name.card }
  let(:answer) { "#{metric_name}+Samsung+2014".card }

  def designer_can action, card
    Card::Auth.as "Joe User" do
      expect(card).to be_ok(action)
    end
  end

  def nondesigner_cant action, card
    Card::Auth.as "Joe Camel" do
      expect(card).not_to be_ok(action)
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
      expect(metric).to be_ok(action)
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

  def self.test_field_permissions base_type, field_list
    field_list.each do |field|
      context "with #{base_type}+#{field}" do
        let(:field_card) { send(base_type).fetch field, new: {} }

        specify "designer can update metric field: #{field}" do
          designer_can :update, field_card
        end

        specify "nondesigner can't update metric field: #{field}" do
          nondesigner_cant :update, field_card
        end
      end
    end
  end

  test_field_permissions :metric, %i[value_type research_policy unit range value_options
                                     report_type question about methodology]
  test_field_permissions :answer, %i[value source]
end
