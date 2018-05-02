# -*- encoding : utf-8 -*-

class MoveCustomizedSkin < Card::Migration
  WIKIRATE_VARIABLES = <<-SCSS.strip_heredoc
    $teal: #03998d !default;
    $primary: $teal !default;
  SCSS

  def up
    ensure_card "*stylesheets", codename: "stylesheets"
    Card::Cache.reset_all
    ensure_card "wikirate skin", type_id: Card::CustomizedBootswatchSkinID
    ensure_card "wikirate stylesheets",
                type_id: Card::SkinID, codename: "wikirate_stylesheets"
    Card::Cache.reset_all
    ensure_card "emergency style hacks", type_id: Card::ScssID
    update_card ["wikirate skin", :stylesheets],
                content: "[[wikirate stylesheets]]\n[[emergency style hacks]]"
    Card["wikirate skin", :colors].update_column :db_content, WIKIRATE_VARIABLES
    update_card [:all, :style], content: "[[wikirate skin]]"
    Card.reset_all_machines
  end
end
