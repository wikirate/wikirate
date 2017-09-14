include_set Abstract::ReportQueries

format do
  def default_header_args _args
    voo.variant = :plural
  end
end
