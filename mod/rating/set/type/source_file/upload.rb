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
    hidden_args = args[:hidden]||{}
    hidden_args.merge! :success=>{:view=>:import}
    super args.merge :hidden=>hidden_args
  end
  view :name_fieldset do |args|
    result = fieldset 'name', raw( name_field form ), :editor=>'name', :help=>args[:help]
    %{
      <div><i class="fa fa-upload" style="display:inline"></i> <h2 style="display:inline">Upload CSV File</h2></div>
      <span>You can upload measure as a CSV file. The file should have two columns, the first contatining company names and the second containing the measurements.</span>
      #{result}
    }
  end
end
