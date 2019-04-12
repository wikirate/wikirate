# -*- encoding : utf-8 -*-

RSpec.describe Card::Set::Abstract::DesignerPermissions do
  def metric
    @metric ||= Card["Joe User+researched number 2"]
  end

  before :all do
    Card::Auth.as_bot do
      metric.research_policy_card.update_attributes! content: "Designer Assessed"
    end
  end

  def designer_can action, card
    Card::Auth.as "Joe User" do
      expect(card.ok?(action)).to be_truthy
    end
  end

  def nondesigner_cant action, card
    Card::Auth.as "Joe Camel" do
      expect(card.ok?(:update)).to be_falsey
    end
  end

  %i[create update delete].each do |action|
    specify "designer can #{action} metric" do
      designer_can action, metric
    end

    specify "nondesigner cannot #{action} metric" do
      nondesigner_cant action, metric
    end

    specify "super user can #{action} metric" do
      Card::Auth.as "Joe Admin" do
        expect(metric.ok?(action)).to be_truthy
      end
    end
  end

  describe "metric fields" do
    def field_card name
      metric.fetch trait: name, new: {}
    end

    %i[value_type].each do |field|
      specify "designer can update metric field: #{field}" do
        designer_can :update, field_card(field)
      end

      specify "nondesigner can't update metric field: #{field}" do
        nondesigner_cant :update, field_card(field)
      end
    end
  end
end