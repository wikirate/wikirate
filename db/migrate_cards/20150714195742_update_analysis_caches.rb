# -*- encoding : utf-8 -*-

class UpdateAnalysisCaches < Card::Migration
  def up
    # Card::Cache.reset_all
    # Card.search(:type=>'analysis').each do |analysis|
    #   analysis.fetch(:trait=>:claim).update_cached_count
    #   analysis.fetch(:trait=>:source).update_cached_count
    # end
  end
end
