# These commands are available in the console when using binding.pry for breakpoints.

def create name='test card', content='some content', type='basic'
  if name.kind_of? Hash
    Card.create! name
  elsif content.kind_of? Hash
    Card.create!(content.merge(:name=>name))
  else
    Card.create! :name=>name, :content=>content, :type=>type
  end
end

def update name='test card', *args
  card_attr = {}
  if args.first.kind_of? String
    card_attr[:content] = args.shift
    card_attr.merge!(args.first)
  else
    card_attr = args.first
  end
  Card.fetch(name).update_attributes card_attr
end

# Shortcut for fetching cards. You can continue to work with the
# last fetched card by calling `fe` without arguments.
# If the first call of `fe` is without argument, fe points to the card "Home"
# Example:
#    fe.name    # => "Home"
#    fe "Basic"
#    fe.name    # => "Basic"
#    fe.type    # => "cardtype"
def fe(name = nil)
  if name
    @fe = Card.fetch name
  else
    @fe ||= Card.fetch "home"
  end
end

def cr(name = nil, content = 'some content', type = 'basic')
  if name
    @cr = create name, content, type
  else
    @cr ||= create
  end
end

def ab
  Card::Auth.as_bot
end

# use syntax highlighting if html is detected
def puts *args
  return super unless args.size == 1
  text = args.first
  return super if !text.is_a?(String) || !(text =~ %r{</\w+>}) || text.include?("\e")
  html = Nokogiri::XML(text, &:noblanks)
  if html.errors.present?
    super text
    puts
    super "WARNING: detected invalid html".red
    super html.errors
  else
    super "with syntax highlighting:\n"
    super CodeRay.scan(html.root.to_s, :html).term
  end
end

def hputs text
  text = Nokogiri::XML(text, &:noblanks).root.to_s
  print CodeRay.scan(text, :html).term
  print "\n"
end

def _a
 @_array ||= (1..6).to_a
end

def _h
  @_hash ||= {hello: "world", free: "of charge"}
end

def _u
  @_user ||= Card.fetch 'Joe User'
end

Pry.config.editor = proc { |file, line| "mine #{file}:#{line}" }

Pry.config.commands.alias_command "h", "hist -T 20", desc: "Last 20 commands"
Pry.config.commands.alias_command "hg", "hist -T 20 -G", desc: "Up to 20 commands matching expression"
Pry.config.commands.alias_command "hG", "hist -G", desc: "Commands matching expression ever used"
Pry.config.commands.alias_command "hr", "hist -r", desc: "hist -r <command number> to run a command"
Pry.config.commands.alias_command "clear", "break --delete-all", desc: "remove all break points"

# Hit Enter to repeat last command
Pry::Commands.command /^$/, "repeat last command" do
  pry_instance.run_command Pry.history.to_a.last
end

if defined?(PryByebug)
  Pry.commands.alias_command 'c', 'continue'
  Pry.commands.alias_command 's', 'step'
  Pry.commands.alias_command 'n', 'next'
  Pry.commands.alias_command 'f', 'finish'
end

# breakpoint commands
Pry.commands.block_command "try", "play expression in current line" do |offset|
  line = target.eval('__LINE__')
  line = line.to_i + offset.to_i if offset
  run "play -e #{line}"
end

Pry.commands.block_command "breakview", "set break point where view is rendered" do |view_name, cardish|
  breakpoint = "break /Users/philipp/dev/decko/gem/card/lib/card/format/render.rb:43"
	if view_name
    breakpoint += " if view.to_sym == \\\'#{view_name}\\\'.to_sym"
  elsif view_name && cardish
    breakpoint += " if view.to_sym == \\\'#{view_name}\\\'.to_sym && card.key == \\\'#{cardish}\\\'.to_name.key"
	end
  run breakpoint
end

Pry.commands.block_command "breaknest", "set break point where nest is rendered" do |card_key|
  breakpoint = "break /Users/philipp/dev/decko/gem/card/lib/card/format/nest.rb:19"
	if card_key
		breakpoint += " if cardish.to_name.key == \\\'#{card_key}\\\'.to_name.key"
	end
  run breakpoint
end

Pry.config.commands.alias_command "bv", "breakview"
Pry.config.commands.alias_command "bn", "breaknest"

puts %{Loaded #{__FILE__}

== Command history ==
h     : hist -T 20 Last 20 commands
hg    : hist -T 20 -G Up to 20 commands matching expression
hG    : hist -G Commands matching expression ever used
hr    : hist -r hist -r <command number> to run a command
Hit Enter to repeat last command

== Variables ==
_u : Card 'Joe User'
_a : [1, 2, 3, 4, 5, 6]
_h : { hello: \"world\", free: \"of charge\" }

== Card commands ==
create : Card.create :name=>$1, :content=>($2||'some content'), :type=>($3||'basic')
update : Card.update :name=>$1, :content=>($2||'some content'), :type=>($3||'basic')
ab     : Card::Auth.as_bot
cr     : create card and assign it to cr (default: name=>'test card', content=>'some content', type=>'basic')
fe     : fetch card and assign it to fe (default: 'Home')

== Breakpoints ==
breakview (bv) : set break point where view is rendered (takes a view name and a card mark as optional argument)
breaknest (bn) : set break point where nest is rendered (takes a card mark as optional argument)
clear          : remove all break points

== Helpful debugger shortcuts ==
hputs : puts with html syntax highlighting
n     : next
s     : step
c     : continue
f     : finish
try   : exexute current line (without stepping forward)
}
