# -*- encoding : utf-8 -*-

class NewHomepageCodenames < Card::Migration
  def up
    ["homepage numbers", "homepage projects",
     "homepage topics", "homepage organizations",
     "homepage video section", "homepage video container",
     "homepage footer",
     "newsletter signup"].each do |name|
      ensure_card name, codename: codename(name)
    end
    merge_cards ["homepage_adjectives", "organizations_using_wikirate"]
    ensure_code_card "countup", Card::JavaScriptID, "script"
    ensure_code_card "wodry", Card::JavaScriptID, "script"
    ensure_code_card "wodry", Card::CssID, "style"
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
                content: %({"type_id":"#{Card.fetch_id type}"})
  end

  def ensure_code_card name, type_id, prefix
    ensure_card "#{prefix}: #{name}",
                codename: "#{prefix}_#{name}",
                type_id: type_id
  end

  def codename name
    name.gsub " ", "_"
  end
end
