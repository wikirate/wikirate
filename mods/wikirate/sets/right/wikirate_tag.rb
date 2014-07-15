require 'byebug'
event :create_missing_tags, :after=>:store, :on=>:save do
	byebug
	if !Card.exists? name  
		Card.create! :type=>"Tag", :name=>name,:subcards=>{'+Article' => {'content'=> '', "type_id"=>"3"} }
	
	end
end