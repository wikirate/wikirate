# -*- encoding : utf-8 -*-

class RemovePdfjsScript < Cardio::Migration
  def up
    codename = "script_pdfjs_hosts"
    Card[:all, :script].drop_item! codename
    delete_code_card codename.to_sym
  end
end
