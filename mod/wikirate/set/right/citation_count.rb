format :html do 
  view :titled do |args|
    args.merge!(:slot_class=>( "no-citations" if card.format.render_core=="0" ))
    super(args)
  end
end
