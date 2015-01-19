include Card::Set::Type::File 

format do 
  include Card::Set::Type::File::Format
end

format :file do 
  include Card::Set::Type::File::FileFormat
end

format :html do
  include Card::Set::Type::File::HtmlFormat
  view :new do |args|
    super args.merge :hidden=>{:success=>{:view=>:import}}
  end
end
