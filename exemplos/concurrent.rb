require 'concurrent'

include Concurrent

def ex1
	soma = AtomicFixnum.new(0)
	threads = []

	2.times {
		threads << Thread.new {
			(1..1000).each do |num|
				soma.set soma.get + num
			end
		}
	}

	threads.each {
		|thr| thr.join
	}

	count += 1
	puts "Resultado: #{soma}"
end

def ex2
	threads = []
	v = ThreadLocalVar.new(14)
	puts "Valor na principal: #{v.value}"

	10.times do |time|
		threads << Thread.new do
			puts "Thread #{time} antes de alterar: #{v.value}"
			v.value = rand(10)
			puts "Thread #{time} alterou: #{v.value}"
		end
	end

	threads.each do |thread|
		thread.join
	end

	puts "Valor na principal: #{v.value}"
end

def ex3
	threads = []
	lista = []
	barreira = CyclicBarrier.new(10)

	10.times do |time|
		threads << Thread.new do
			lista << rand(10)
			puts "Thread #{time} vai esperar as demais"
			barreira.wait

			lista[time] = (lista[(time-1)%10] + lista[(time+1)%10])
			puts "Thread #{time} esperando denovo"
			barreira.wait

			lista[time] -= (lista[(time-1)%10] - lista[(time+1)%10])
		end
	end

	threads.each do |thread|
		thread.join
	end

	puts "Valor final #{lista}"
end

def ex4
	threads = []
	exchanger = Exchanger.new

	threads << Thread.new do
		nome = "Thread A"
		recebido = exchanger.exchange nome
		puts "#{nome} recebeu #{recebido}"
	end

	threads << Thread.new do
		nome = "Thread B"
		recebido = exchanger.exchange nome
		puts "#{nome} recebeu #{recebido}"
	end

	threads.each do |thread|
		thread.join
	end
end

def ex5
p = Promise.fulfill(20).
    then{|result| puts "#{result-10}"; result-10 }.
    then{|result| puts "#{result*3}"; result*3 }.
    then{|result| puts "#{result%5}"; result % 5 }.execute

sleep 0.2
end

# gem install concurrent-ruby -v 1.0.5
#ex1 # AtomicFixnum
ex2 # ThreadLocalVar
#ex3 # CyclicBarrier
#ex4 # Exchanger
#ex5 # Promise