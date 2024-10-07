namespace :wikirate do
  desc "output current WikiRate version"
  task :version do
    puts wikirate_version
  end

  desc "tag version and push to github"
  task :release do
    version = wikirate_version
    system %(
      git tag -a v#{version} -m "WikiRate Version #{version}"
      git push --tags wikirate
    )
  end

  def wikirate_version
    File.open(File.expand_path("../../../../../VERSION", __FILE__)).read.chomp
  end
end
