
def item_names args={}
  limit = Env::params[:limit] || 5
  Card::Act.select(:actor_id).distinct.where("card_id is not NULL and actor_id <> #{Card["wagn bot"]} and actor_id <> #{Card["Anonymous"]}").order('id DESC').limit(limit).map do |act|
    Card[act.actor_id].id
  end
end

