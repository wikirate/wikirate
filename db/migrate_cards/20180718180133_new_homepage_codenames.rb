# -*- encoding : utf-8 -*-

class NewHomepageCodenames < Card::Migration
  def up
    ensure_code_card "homepage numbers"
    ensure_code_card "homepage projects"
    ensure_code_card "homepage topics"
    ensure_code_card "homepage organizations"
    ensure_code_card "homepage video section"
    ensure_code_card "homepage footer"
    ensure_code_card "homepage adjectives", type: :pointer
    ensure_code_card "newsletter signup"
    ensure_code_card "script: wodry", type_id: Card::JavaScriptID
    ensure_code_card "style: wodry", type_id: Card::CssID
    %w[companies projects topics answers].each do |type|
      feature_list_card type
    end

    Card::Cache.reset_all
  end

  def feature_list_card type
    name = "featured #{type}"
    ensure_code_card name, type_id: Card::PointerID
    ensure_card [name, :self, :options],
                type_id: Card::SearchTypeID,
                content: %({"type_id":"#{Card.fetch_id type}"})
  end
end
