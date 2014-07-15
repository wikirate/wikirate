event :create_missing_tags, :after=>:store, :on=>:save do
	full_tagname = Card[name].content
	tagname = full_tagname[2..full_tagname.length-3]
	
	if !Card.exists? tagname  
		Card.create! :type=>"Tag", :name=>tagname,:subcards=>{'+Article' => {'content'=> '', "type_id"=>"3"} }
	
	end
end