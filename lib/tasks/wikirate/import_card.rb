class ImportCard
  def initialize attr
    @attr = attr
    adjust_file_attributes
    @name = @attr["name"]
    @codename = @attr["codename"]
    @card = fetch_card
  end

  def update_or_create
    puts(update || create)
  rescue => e
    puts "Error in #{@name}\n#{e}".red
  end

  private

  def update
    return unless @card
    "updating card #{@name} #{@card.update_attributes!(@attr)}".light_blue
  end

  def create
    "creating card #{@name} #{Card.create!(@attr)}".yellow
  end

  def fetch_card
    (@codename && Card.find_by_codename(@codename)) || Card.fetch(@name)
  end

  def adjust_file_attributes
    return unless @attr["type"].in? %w(Image File)
    if bucket_file?
      # TODO: check if the bucket is configured and only then keep it as a cloud file?
      @attr["storage_type"] = :cloud
    else
      @attr["content"] = ""
    end
    @attr["empty_ok"] = true
  end

  def bucket_file?
    @attr["content"].match?(/^\(\w+\)/)
  end
end
