# -*- encoding : utf-8 -*-

RSpec.describe Card::Set::Abstract::DesignerPermissions do
  let(:metric_name) { "Joe User+researched number 3" }
  let(:metric) { metric_name.card }
  let(:record) { "#{metric_name}+Samsung+2014".card }

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

  describe "records" do
    %i[create update delete].each do |action|
      specify "designer can #{action} record" do
        designer_can action, record
      end

      specify "nondesigner cannot #{action} record" do
        nondesigner_cant action, record
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
  test_field_permissions :record, %i[value source]
end
