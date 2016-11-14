

def filter_args args
  allow(card).to receive(:filter_keys_with_values) { args }
end
