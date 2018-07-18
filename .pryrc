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

def _array
 @_array ||= (1..6).to_a
end

def _hash
  @_hash ||= {hello: "world", free: "of charge"}
end

def _user
  @_user ||= Card.fetch 'Joe User'
end

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

Pry.config.editor = proc { |file, line| "mine #{file}:#{line}" }

Pry.config.commands.alias_command "h", "hist -T 20", desc: "Last 20 commands"
Pry.config.commands.alias_command "hg", "hist -T 20 -G", desc: "Up to 20 commands matching expression"
Pry.config.commands.alias_command "hG", "hist -G", desc: "Commands matching expression ever used"
Pry.config.commands.alias_command "hr", "hist -r", desc: "hist -r <command number> to run a command"
Pry.config.commands.alias_command "clear", "break --delete-all", desc: "remove all break points"

if defined?(PryByebug)
  Pry.commands.alias_command 'c', 'continue'
  Pry.commands.alias_command 's', 'step'
  Pry.commands.alias_command 'n', 'next'
  Pry.commands.alias_command 'f', 'finish'
end

# Hit Enter to repeat last command
Pry::Commands.command /^$/, "repeat last command" do
  _pry_.run_command Pry.history.to_a.last
end


def hputs text
  text = Nokogiri::XML(text, &:noblanks).root.to_s
  puts CodeRay.scan(text, :html).term
end


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

puts %{Loaded ~/.pryrc

Helpful shortcuts:
h     : hist -T 20 Last 20 commands
hg    : hist -T 20 -G Up to 20 commands matching expression
hG    : hist -G Commands matching expression ever used
hr    : hist -r hist -r <command number> to run a command
try   : exexute current line (without stepping forward)
clear : remove all break points

Special card commands:
breakview (bv) : set break point where view is rendered (takes a view name as optional argument)
create         : Card.create :name=>$1, :content=>($2||'some content'), :type=>($3||'basic')
update         : Card.update :name=>$1, :content=>($2||'some content'), :type=>($3||'basic')
ab             : Card::Auth.as_bot

Variables
_user  : Card 'Joe User'
_array : [1, 2, 3, 4, 5, 6]
_hash  : { hello: \"world\", free: \"of charge\" }
fe     : fetch card and assign it to fe (default: 'Home')
cr     : create card and assign it to cr (default: name=>'test card', content=>'some content', type=>'basic')
up     : update card and assign it to up (default: name=>'test card', content=>'some content', type=>'basic')

Hit Enter to repeat last command

}
