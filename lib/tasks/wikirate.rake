require "colorize"

namespace :wikirate do
  desc "fetch json from export card on dev site and generate migration"
  task import_from_dev: :environment do
    import_cards do
      json = open("http://dev.wikirate.org/export.json").read
      JSON.parse(json).deep_symbolize_keys
    end
  end

  desc "fetch json from local export card and generate migration"
  task import_from_local: :environment do
    import_cards do
      Card["export"].format(format: :json).render_content
    end
  end

  def import_cards
    return unless (filename = import_data_filename)
    require "card/migration"
    require "generators/card"
    import_data = yield
    write_card_content! import_data
    write_card_attributes filename, import_data[:card][:value]
    system "bundle exec decko generate card:migration #{ENV['name']}"
  end

  def write_card_attributes filename, card_attributes
    path = Card::Migration.data_path("#{filename}.json")
    File.open(path, "w") do |f|
      f.print JSON.pretty_generate(card_attributes)
    end
  end

  # removes and writes the content field
  def write_card_content! import_data
    import_data[:card][:value].each do |card_attr|
      path = File.join "cards", card_attr[:name].to_name.key
      File.open(Card::Migration.data_path(path), "w") do |f|
        f.puts card_attr.delete :content
      end
    end
  end

  def import_data_filename
    if !ENV["name"]
      puts "pass a name for the migration 'name=...'"
    elsif  ENV["name"] !~ /^(?:import)_(.*)(?:\.json)?/
      puts "invalid format: name must match /import_(.*)/"
    else
      Regexp.last_match(1)
    end
  end

  desc "test the performance for a list of pages"
  task benchmark: :environment do
    def wbench_results_to_html results
      list = ""
      results.browser.each do |key, value|
        list += %(
                <li class="list-group-item">
                  <span class="badge">#{value}</span>
                  #{key}
                </li>
              )
      end
      %(
        <ul class="list-group">
          #{list}
        </ul>
      )
    end

    # host = 'http://dev.wikirate.org'
    host = "http://localhost:3000"

    test_pages = ENV["page"] ? [ENV["page"]] : ["Home"]
    # test_pages = ENV['name'] ? [ENV['name']] : ['Home']
    runs = ENV["run"] || 1
    test_pages.each do |page|
      puts page

      log_args = { performance_log: {
        output: :card, output_card: page,
        methods: %i(
          execute rule fetch view
        ), details: true, min_time: 1
      } }
      url = "#{host}/#{page}"
      open "#{url}?#{log_args.to_param}"
      benchmark = WBench::Benchmark.new(url) { "" }
      results   = benchmark.run(runs) # => WBench::Results
      card = Card.fetch "#{page}+#{Card[:performance_log].name}",
                        new: { type_id: Card::PointerID }
      card.add_csv_entry page, results, runs
    end

    # results.app_server # =>
    #   [25, 24, 24]
    #
    # results.browser # =>
    #   {
    #     "navigationStart"            => [0, 0, 0],
    #     "fetchStart"                 => [0, 0, 0],
    #     "domainLookupStart"          => [0, 0, 0],
    #     "domainLookupEnd"            => [0, 0, 0],
    #     "connectStart"               => [12, 12, 11],
    #     "connectEnd"                 => [609, 612, 599],
    #     "secureConnectionStart"      => [197, 195, 194],
    #     "requestStart"               => [609, 612, 599],
    #     "responseStart"              => [829, 858, 821],
    #     "responseEnd"                => [1025, 1053, 1013],
    #     "domLoading"                 => [1028, 1055, 1016],
    #     "domInteractive"             => [1549, 1183, 1136],
    #     "domContentLoadedEventStart" => [1549, 1183, 1136],
    #     "domContentLoadedEventEnd"   => [1549, 1184, 1137],
    #     "domComplete"                => [2042, 1712, 1663],
    #     "loadEventStart"             => [2042, 1712, 1663],
    #     "loadEventEnd"               => [2057, 1730, 1680]
    #   }
  end

  namespace :task do
    desc "remove empty metric value cards"
    task remove_empty_metric_value_cards: :environment do
      # require File.dirname(__FILE__) + '/../config/environment'
      # Card::Auth.as_bot
      Card::Auth.current_id = Card::WagnBotID

      Card.search(type: "Metric") do |metric|
        puts "~~~\n\nworking on METRIC: #{metric.name}"

        value_groups = Card.search(
          left_id: metric.id,
          right: { type: "Company" },
          not: {
            right_plus: [
              { type: "Year" },
              { type: "Metric Value" }
            ]
          }
        )

        puts "deleting #{value_groups.size} empty value cards"
        value_groups.each do |group_card|
          begin
            group_card.descendants.each do |desc|
              desc.update_column :trash, true
            end
            group_card.update_column :trash, true
          rescue
            puts "FAILED TO DELETE: #{group_card.name}"
          end
        end
      end
      puts "empty trash"
      Card.empty_trash
    end

    desc "delete all cards that are marked as trash"
    task "empty_trash" => :environment do
      Card.empty_trash
    end
  end
end
