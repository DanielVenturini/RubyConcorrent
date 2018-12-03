$var1 = 0
$var2 = 0
$mutex = Mutex.new
#$mutex = Monitor.new

# auxiliar ao exemplo 1
def somaDecrementa
	# regiao critica
	$var1 += 1
	$var2 -= 1
end

# auxiliar ao exemplo 2
def somaDecrementaSynchronized
	$mutex.synchronize {
		# regiao critica com exclusão mútua
		$var1 += 1
		$var2 -= 1
	}
end

# auxiliar ao exemplo 3
def regiaoExclusiva
	puts "Tentando acessar o synchronize"
	$mutex.synchronize do
		puts "Conseguiu entrar no bloco synchronize"
		sleep 2
		puts "Saindo do synchronize"
	end
end

def ex1
	threads = []
	10_000.times do
		threads << Thread.new {
			somaDecrementa
		}
	end

	threads.each { |thread|
		thread.join
	}

	puts "Var1: #{$var1}"
	puts "Var2: #{$var2}"
end

def ex2
	threads = []
	10_000.times do
		threads << Thread.new {
			somaDecrementaSynchronized
		}
	end

	threads.each { |thread|
		thread.join
	}

	puts "Var1: #{$var1}"
	puts "Var2: #{$var2}"
end

def ex3
	thr = Thread.new do
		regiaoExclusiva
	end

	if not $mutex.locked?
		puts "Nao esta bloqueada ainda"
		$mutex.lock
		puts "Obteve o lock"
		sleep 2
		puts "Saindo do lock"
		$mutex.unlock
	end

	thr.join
end

def ex4
	items = []
	lock = Mutex.new
	cond = ConditionVariable.new
	limit = 0

	produtor = Thread.new do
		loop do
			lock.synchronize do
				qtde = rand(50)
				next if qtde == 0

				puts "produzindo #{qtde} item(s)"
				items = Array.new(qtde,"item")
				cond.wait(lock)
				puts "consumo efetuado!"
				puts "-" * 25
				limit += 1
			end
			break if limit > 5
		end
	end

	consumidor = Thread.new do
		loop do
			lock.synchronize do
				if items.length>0
					puts "consumindo #{items.length} item(s)"
					items = []
				end

			cond.signal		# se fosse varios produtores: cond.broadcast
			end
		end
	end

	produtor.join
end


#ex1
#ex2
#ex3
ex4