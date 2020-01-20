# -*- encoding : utf-8 -*-

class AnswerHelpText < Card::Migration
  HELP_TEXT = <<-HTML.strip_heredoc
    <p>
      What is the answer to the question this metric asks?
      <a class="pl-1" data-toggle="popover" data-content="view methodology to learn about how to answer" href="#" data-original-title="" title="">
        <i class="fa fa-question-circle"></i>
      </a>
    </p>
  HTML

  def up
    ensure_card "Answer+value+*type_plus_right+*help",
                type_id: Card::HtmlID, content: HELP_TEXT
  end
end
