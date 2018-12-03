$var1 = 0
$var2 = 0
$mutex = Mutex.new

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



#ex1
ex2