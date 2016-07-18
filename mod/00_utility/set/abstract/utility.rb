
def fetch_params params
  Env.params.select { |key, val| val && params.include?(key) }
     .with_indifferent_access
end
