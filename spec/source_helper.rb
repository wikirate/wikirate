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

  def source_args args={}
    {
      type_id: Card::SourceID,
      subcards: {
        "+File" => { type_id: Card::FileID },
      }
    }
  end
end
