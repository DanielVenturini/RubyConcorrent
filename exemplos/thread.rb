class Despertador
	def initialize horario, nome
		@horario = horario
		@nome = nome
	end

	def nome
		@nome
	end

	def start outro_despertador
		Thread.new {
			puts "#{@nome} Esperando dar a hora..."
			sleep(@horario)
			puts "#{@nome} despertando.............."
			puts "Desligando despertador #{outro_despertador.nome}"

			exit
			outro_despertador.kill
		}
	end
end

def ex1
	thr = Thread.new {
		[0,1,2,3,4,5,6,7,8,9].each do |pos|
			puts "Thread na posicao #{pos}"
		end
	}
end

def ex2
	thr = Thread.new {
		[0,1,2,3,4,5,6,7,8,9].each do |pos|
			puts "Thread na posicao #{pos}"
		end
	}

	thr.join
end

def ex3
	threads = []
	vetor = [0,1,2,3,4,5,6,7,8,9]

	(10-1).times {
		|pos| threads << Thread.new {
			puts "Meu subvetor #{vetor[pos...pos+2]}"
		}
	}

	puts "Aguardando as threads finalizarem"
	threads.each {
		|thr| thr.join
	}
end

def ex4
	threads = []
	@var = 0

	(10-1).times {
		threads << Thread.new {
			@var += 1
			puts "Meu incremento #{@var}"
		}
	}

	threads.each {
		|thr| thr.join
	}
end

def ex5
	puts "Ligando os despertadores..."

	t1 = Despertador.new(3, 'Roseta')
	t2 = Despertador.new(5, 'Tomar')

	t1 = t1.start t2
	t2 = t2.start t1

	puts "Despertadores ligados!"
	t1.join
	t2.join
end

=begin
	Chamadas de funções para os exemplos
=end

#ex1
#ex2
#ex3
#ex4
#ex5