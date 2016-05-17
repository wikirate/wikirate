describe Card::Set::Type::MetricValue::Views do
  # FIXME: not the right rspec syntax
  # humanized_number doesn't change anything
  describe '#huminzed_number' do
    subject { @number = Card["Jedi+deadliness+Death Star+1977"].format
              .humanized_number(@number) }
    specify do
      @number = "1_000_001"
      expect{subject}.to change{ @number }.from("1_000_001").to("1M")
    end
    specify do
      @number = "0.00000123345"
      expect{subject}.to change{ @number }.from("0.00000123345").to("0.00000123")
    end
    specify do
      @number = "0.001200"
      expect{subject}.to change{ @number }.from("0.001200").to("0.0012")
    end
    specify do
      @number = "123.4567"
      expect{subject}.to change{ @number }.from("123.4567").to("123.5")
    end
  end
end