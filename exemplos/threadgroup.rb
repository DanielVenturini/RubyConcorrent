tg = ThreadGroup.new

t1 = Thread.new {
	puts "Thread1 #{Thread.current.group}"
}

t2 = Thread.new {
	puts "Thread2 #{Thread.current.group}"
}

t3 = Thread.new {
	puts "Thread3 #{Thread.current.group}"
}

tg.add(t1)
tg.add(t2)
tg.add(t3)
tg.enclose

t1.join
t2.join
t3.join

puts "#{ThreadGroup::Default.list}"

tg.add Thread.new { 	# erro -> thread sendo adicionada em grupo fechado
	puts "Thread criada internamente #{Thread.current.group}"
}