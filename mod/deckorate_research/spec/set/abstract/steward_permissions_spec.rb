# -*- encoding : utf-8 -*-

RSpec.describe Card::Set::Abstract::StewardPermissions do
  let(:metric_name) { "Joe User+researched number 3" }
  let(:metric) { metric_name.card }
  let(:answer) { "#{metric_name}+Samsung+2014".card }

  def steward_can action, card
    Card::Auth.as "Joe User" do
      expect(card).to be_ok(action)
    end
  end

  def nonsteward_cant action, card
    Card::Auth.as "Joe Camel" do
      expect(card).not_to be_ok(action)
    end
  end

  %i[create update delete].each do |action|
    specify "steward can #{action} metric" do
      steward_can action, metric
    end

    specify "nonsteward cannot #{action} metric" do
      nonsteward_cant action, metric
    end

    specify "super user can #{action} metric", with_user: "Joe Admin"  do
      expect(metric).to be_ok(action)
    end
  end

  describe "answers" do
    %i[create update delete].each do |action|
      specify "steward can #{action} answer" do
        steward_can action, answer
      end

      specify "nonsteward cannot #{action} answer" do
        nonsteward_cant action, answer
      end
    end
  end

  def self.test_field_permissions base_type, field_list
    field_list.each do |field|
      context "with #{base_type}+#{field}" do
        let(:field_card) { send(base_type).fetch field, new: {} }

        specify "steward can update metric field: #{field}" do
          steward_can :update, field_card
        end

        specify "nonsteward can't update metric field: #{field}" do
          nonsteward_cant :update, field_card
        end
      end
    end
  end

  test_field_permissions :metric, %i[value_type assessment unit range value_options
                                     report_type question about methodology]
  test_field_permissions :answer, %i[value source]
end
