# -*- encoding : utf-8 -*-

class RemoveContentOfCodedCards < Card::Migration
  DEPRECATED = %i[
     style_top_bar
     style_overview_item
     style_company_and_topic_item
     style_note
     style_user_following_list
     style_wikirate_bootstrap_navbar
     style_wikirate_bootstrap_form
     style_wikirate_bootstrap_common
     style_images
     style_profile_page
     style_company_header
     style_source_preview
     style_wikirate_layout
     style_wikirate_responsiveness
     style_wikirate_bootstrap_tabs
     style_wikirate_font_icon
     style_bootstrap_modal_fix
     style_wikirate_bootstrap_table
     style_wikirate_progress_bar
     style_project
     style_browse_items
     chosen_style
     coded_stylesheets
     style_drag_and_drop
     script_answer_source_handling
     script_metric_value
     script_value_type
     script_drag_and_drop
     script_metric_chart
    ]

  def up
    ensure_style_cards :wikirate, :filter, :homepage, :research, :source, :slick, :fakeloader
    ensure_script_cards :wikirate, :metrics, :source, :homepage, :research, :source
    ensure_js_cards :fakeloader, :readmore, :slick

    DEPRECATED.each do |codename|
      delete_code_card codename
    end

    delete_card "script: wikirate scripts"
    Card.fetch([:all, :script]).drop_item! "script: wikirate scripts"

    remove_js_libraries

    Card::Set::Self::ScriptWikirate::FILE_NAMES.each do |file|
      delete_code_card "script_#{file}"
    end

    ensure_card "wikirate skin", codename: "wikirate_skin",
                type_id: Card::CustomizedBootswatchSkinID
  end

  def ensure_style_cards *names
    ensure_code_cards names, Card::ScssID, "style"
  end

  def ensure_script_cards *names
    ensure_code_cards names, Card::CoffeeScriptID, "script"
  end

  def ensure_js_cards *names
    ensure_code_cards names, Card::JavaScriptID, "script"
  end

  def ensure_code_cards names, type_id, prefix
    names.each do |name|
      ensure_code_card name, type_id, prefix
    end
  end

  def ensure_code_card name, type_id, prefix
    ensure_card "#{prefix}: #{name}",
                codename: "#{prefix}_#{name}",
                type_id: type_id
  end

  def remove_js_libraries
    delete_card "chosen proto script"
    delete_card "chosen script"
    if (card = Card.fetch("script: libraries"))
      card.drop_item "chosen proto script"
      card.drop_item "chosen script"
      card.save!
    end
  end
end
