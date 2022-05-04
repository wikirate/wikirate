# support filter testing
module FilterSpecHelper
  def filter_args args
    allow(format).to receive(:filter_keys_with_values) { args }
  end

  def add_filter field, value
    Card::Env.params[:filter] ||= {}
    Card::Env.params[:filter][field] = value
  end
end
