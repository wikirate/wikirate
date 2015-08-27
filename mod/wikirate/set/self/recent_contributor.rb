
def item_names args={}
  limit = Env::params[:limit] || 5
  Card::Act.select(:actor_id).distinct.where("card_id is not NULL and actor_id <> 1 and actor_id <> 15").order('id DESC').limit(limit).map do |act|
    Card[act.actor_id].id
  end
end

