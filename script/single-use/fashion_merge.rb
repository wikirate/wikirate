# require File.expand_path("../../config/environment",  __FILE__)

require_relative "../../config/environment"

MERGE_COMPANIES = { carter_s_inc: :carter_inc,
                    chico_s_fa_inc: :chico_fa_inc,
                    h_m: :h_m_henne_mauritz_ab,
                    mark_and_spencer_group_plc: :mark_spencer }.freeze

Card::Auth.as_bot do
  MERGE_COMPANIES.each do |keep, remove|
    Card[remove.to_s].merge_into keep.to_s
  end
end
