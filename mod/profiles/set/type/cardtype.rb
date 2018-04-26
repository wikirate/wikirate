include_set Abstract::ReportQueries

format do
  before :header do
    voo.variant = :plural
  end
end
