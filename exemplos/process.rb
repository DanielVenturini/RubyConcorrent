def ex1
	range = 0...10_000_000
	number = 8_888_888

	puts range.to_a.index(number)
end

def ex2
	range1 = 0...2_500_000
	range2 = 2_500_000...5_000_000
	range3 = 5_000_000...7_500_000
	range4 = 7_500_000...10_000_000
	number = 8_888_888

	puts "PID Pai #{Process.pid}"
	fork { puts "PID Filho1 #{Process.pid}: #{range1.to_a.index(number)}" }
	fork { puts "PID Filho2 #{Process.pid}: #{range2.to_a.index(number)}" }
	fork { puts "PID Filho3 #{Process.pid}: #{range3.to_a.index(number)}" }
	fork { puts "PID Filho4 #{Process.pid}: #{range4.to_a.index(number)}" }
	Process.wait
end

=begin
	Chamadas de funções para os exemplos
=end

#ex1
#ex2