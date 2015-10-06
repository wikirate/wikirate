# -*- encoding : utf-8 -*-

class InitiativeParticipant < Card::Migration
  def up

    cardname = "Initiative+Participants+*type plus right+*structure"
    participant_search_card = Card.fetch cardname
    participant_search_card.delete if participant_search_card

    if card = Card["Participant"]
      card.codename = :participant
      card.save!
    end

    initiatives = Card.search type_id: Card::CampaignID
    initiatives.each do |initiative|
      # create a pointer card called initiative+participant
      initiative_name = initiative.name
      if !Card.exists? "#{initiative_name}+participant"
        participant = Card.create name: "#{initiative_name}+participant"
          , type_id: Card::PointerID 
      end
    end
  end
end
