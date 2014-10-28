format :html do 
  view :titled do |args|
    args.merge!(:slot_class=>( card.format.render_core=="0" ? "red-citation" : "green-citation" ))
    super(args)
  end
end
