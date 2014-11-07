# -*- encoding : utf-8 -*-

class ImportSourcePreviewScriptForUndefinedTagAndClaimBox < Wagn::Migration
  def up
          import_json "source_preview_script_for_undefined_tag_and_claim_box.json"
      end
end
