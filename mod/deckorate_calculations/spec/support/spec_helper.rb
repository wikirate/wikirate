RSpec.configure do |config|
  config.before do
    puts "spectracular: #{Card["Jedi+disturbances in the Force+SPECTRE+2000"]&.name}"
  end
end
