def virtual?; true end
format :html do
  view :raw do |args|
    
    closed_task_number = Card.search :found_by=>card.cardname.left+"+tasks",:right_plus=>["Status",{:refer_to=>"Closed"}],:return=>"count"
    all_task_number = Card.search :found_by=>card.cardname.left+"+tasks",:return=>"count"

    if all_task_number == 0 
      0
    else
      (closed_task_number.to_i*100)/all_task_number.to_i
    end
  end

end
