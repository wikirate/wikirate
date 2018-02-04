# -*- encoding : utf-8 -*-

class AddHowToResearchCard < Card::Migration
  CONTENT = <<-HTML.strip_heredoc.freeze
      <div class="col-md-6 col-centered text-center text-vertically-centered light-grey-color-2 _blank_state_message">
        <br />
        <p>
          How to Research an Answer
        </p>
        <ol class="text-left">
          <li>Choose a metric, company, and year.</li>
          <li>Look for the answer to the metric's question in suggested (or other) sources.</li>
          <li>Enter the answer and supporting comments</li>
          <li>Cite the source</li>
          <li>Submit!</li>
        </ol>
      </div>
  HTML

  def up
    ensure_card "how to research", codename: "how_to_research",
                                               content: CONTENT,
                                               type: :html
  end
end
