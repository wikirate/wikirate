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
    #  rescue => e
    # puts "Error in #{@name}\n#{e}".red
  end

  private

  def update
    return unless @card
    name = @attr.delete "name"
    @card.update! name: name if name && name != @card.name
    @card.update!(@attr)
    "updated: #{@name}".light_blue
  end

  def create
    Card.create! @attr
    "created: #{@name}".yellow
  end

  def fetch_card
    (@codename && Card.find_by_codename(@codename)) || Card.fetch(@name)
  end

  def adjust_file_attributes
    return unless @attr["type"].in? ["Image", "File", "Source Import File", "Metric Answer Import File"]
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
