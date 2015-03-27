format :html do

  view :new do |args|
    hidden_args = args[:hidden]||{}
    hidden_args.merge! :success=>{:view=>:import}
    super args.merge :hidden=>hidden_args
  end
  # view :name_formgroup do |args|
  #   result = formgroup 'name', raw( name_field form ), :editor=>'name', :help=>args[:help]
  #   %{
  #     <div><i class="fa fa-upload fa-2" style="display:inline"></i> <h2 style="display:inline">Upload CSV File</h2></div>
  #     <span>You can upload measure as a CSV file. The file should have two columns, the first containing company names and the second containing the measurements.</span>
  #     #{result}
  #   }
  # end
end
