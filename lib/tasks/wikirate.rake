require "colorize"

namespace :wikirate do
  task :version do
    puts wikirate_version
  end

  task :release do
    version = wikirate_version
    system %(
      git tag -a v#{version} -m "WikiRate Version #{version}"
      git push --tags wikirate
    )
  end

  task :new_with_subject do
    load_dump dump_path
    Rake::Task["wikirate:change_subject"].invoke
  end

  task change_subject: :environment do
    _task, subject = ARGV
    Card::Cache.reset_all
    Card::Auth.as_bot do
      Card[:company].update! name: subject, update_referers: true
      Card.search(type_id: Card::MetricID) do |card|
        card.update! codename: nil if card.codename.present?
        card.delete!
      end
      Card.search(type_id: Card::CompanyID) do |card|
        card.delete! unless card.codename.present?
      end

      [["Company", subject], ["Companies", subject.pluralize]].each do |old, new|
        sub_in_db old, new
      end
    end
    exit
  end

  desc "pull from decko repository to vendor/decko and commit"
  task :decko_tick do
    _task, branch = ARGV
    branch ||= "wikirate"
    psystem "cd vendor/decko && git pull origin #{branch}"
    psystem "git commit vendor/decko -m 'decko tick'"
    exit
  end

  def psystem cmd
    puts cmd.green
    system cmd
  end

  def sub_in_db old, new
    Card.search(name: ["match", old]).uniq.each do |card|
      next unless card.simple?
      new_name =
        card.name.gsub(old.capitalize, new.capitalize).gsub(old.downcase, new.downcase)
      card.update! name: new_name, update_referers: true
    end
    Card.search(content: ["match", old]) do |card|
      new_content =
        card.db_content
            .gsub(/\b#{old.capitalize}\b/, new.capitalize)
            .gsub(/\b#{old.downcase}\b/, new.downcase)
      card.update! db_content: new_content
    end
  end

  def wikirate_version
    File.open(File.expand_path("../../../VERSION", __FILE__)).read.chomp
  end
end
