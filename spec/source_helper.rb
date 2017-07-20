module SourceHelper
  def create_page url: "http://www.google.com/?q=wikirate", subcards: {},
                  box: true, import: false

    Card::Auth.as_bot do
      with_sourcebox box do
        Card.create! type_id: Card::SourceID,
                     subcards: { "+Link" => { content: url } }.merge(subcards),
                     import: import
      end
    end
  end

  def create_link_source url
    create_source link: url
  end

  def create_source args
    Card.create source_args(args)
  end

  def with_sourcebox sourcebox=true
    Card::Env.params[:sourcebox] = sourcebox.to_s
    yield
  ensure
    Card::Env.params[:sourcebox] = "false"
  end

  def source_args args
    res = {
      type_id: Card::SourceID,
      subcards: {
        "+Link" => {},
        "+File" => { type_id: Card::FileID },
        "+Text" => { type_id: Card::BasicID, content: "" }
      }
    }
    source_type_name = Card[:source_type].name
    add_source_type args, res, source_type_name
    res
  end

  def add_source_type args, res, source_type_name
    [:link, :file, :text].each do |key|
      next unless args[key]
      content_key = (key == :file ? :file : :content)
      res[:subcards]["+#{key.to_s.capitalize}"][content_key] = args[key]
      res[:subcards]["+#{source_type_name}"] = {}
      res[:subcards]["+#{source_type_name}"][:content] = "[[#{key}]]"
    end
  end
end
