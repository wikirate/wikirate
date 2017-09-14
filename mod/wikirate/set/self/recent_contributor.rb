# this is pretending as a pointer card
# to get the recent contributor, query the ids and names from the act table to
# get recent editors
def item_names _args={}
  # may need different number of editors
  limit = Env.params[:limit] || 5
  # this where clause to get recent editors(except wagn bot and annonymous)
  # and the acted card should not be null
  where_clause = "card_id is not NULL and actor_id <> #{Card::WagnBotID} " \
                 "and actor_id <> #{Card['Anonymous'].id}"

  Card::Act.select(:actor_id).distinct.where(where_clause)
           .order("id DESC").limit(limit).map do |act|
    Card[act.actor_id].name
  end
end
