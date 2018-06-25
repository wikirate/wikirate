# -*- encoding : utf-8 -*-

class RemoveDuplicateAnswers < Card::Migration
  def up
    duplicates.each do |dup|
      wipe_duplicate dup
      if researched?(dup)
        refresh_researched(dup)
      else
        refresh_calculated(dup)
      end
    end
  end

  def researched? dup
    Card[dup.metric_id].researched?
  end

  def refresh_researched dup
    researched = card dup
    Answer.create! researched if researched
  end

  def card dup
    Card.fetch dup.metric_id, dup.company_id, dup.year.to_s
  end

  def refresh_calculated dup
    card(dup)&.delete! skip_event: %i[update_related_calculations update_related_scores]
    Card[dup.metric_id].update_value_for! company: dup.company_id, year: dup.year
  end

  def duplicates
    Answer.select(:company_id, :metric_id, :year)
        .group(:company_id, :metric_id, :year)
        .having("count(*) > 1")
  end

  def wipe_duplicate dup
    Answer.where(
      company_id: dup.company_id,
      metric_id: dup.metric_id,
      year: dup.year
    ).destroy_all
  end
end
