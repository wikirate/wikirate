# -*- encoding : utf-8 -*-

class ExampleAnswers < Card::Migration
  def up
    ensure_card "Example Answers", codename: "example_answers"
  end
end
