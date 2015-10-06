# -*- encoding : utf-8 -*-

class InitiativeParticipant < Card::Migration
  def up
    participant_search_card = Card.fetch "Initiative+Participants+*type plus right+*structure"
    participant_search_card.delete if participant_search_card

    if card = Card["Participant"]
      card.codename = :participant
      card.save!
    end

    initiatives = Card.search type_id: Card::CampaignID
    initiatives.each do |initiative|
      # create a pointer card called initiative+participant
      initiative_name = initiative.name
      participant = Card.create name: "#{initiative_name}+participant", type_id: Card::PointerID if !Card.exists? "#{initiative_name}+participant"
    end
  end
end
