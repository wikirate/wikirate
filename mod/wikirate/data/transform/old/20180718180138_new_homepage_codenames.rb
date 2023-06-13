# -*- encoding : utf-8 -*-

class NewHomepageCodenames < Cardio::Migration::Transform  def up
    %w[companies projects topics answers].each do |type|
      feature_list_card type
    end

    Card::Cache.reset_all
  end

  def feature_list_card type
    name = "homepage featured #{type}"
    content = File.read data_path(File.join("cards", name.to_name.key))
    ensure_card name, type_id: Card::PointerID, content: content, codename: codename(name)
    ensure_card [name, :self, :options],
                type_id: Card::SearchTypeID,
                content: %({"type_id":"#{type.card_id}"})
  end
end
