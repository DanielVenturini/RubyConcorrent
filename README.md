# Programação Concorrente em Ruby

<img align="left" src="https://github.com/DanielVenturini/RubyConcorrent/blob/master/imagens/logo.png">

```Ruby``` é uma linguagem de programação interpretada, multiparadigma e fracamente tipada, desenvolvida em 1995 por Yukihiro Matsumoto. Inicialmente, seu projeto era para se tornar uma linguagem de script. A ídeia era criar uma liguagem mais poderosa que ```Perl``` e com mais orientação a objetos do que ```Python```.

Os mecanismos de concorrência, paralelismo e sincronização em Ruby naõ são tão diversos; nativamente é provido simples ```Mutex``` e ```Threads```. Outras estruturas mais avançadas como, ```Barriers``` e ```Pool```, pode ser encontrados nas ```Gems``` do Ruby, que são implementações fornecidas pela comunidade.

Todos os códigos aqui apresentados foram executados com o ```Ruby 2.5.3``` e ```JRuby 1.7.22```.

## Processos
Este é o módulo para manipulação de processos do SO. Com este não é possível realizar muitas operações comparando com a class ```Threads```. Este não provê concorrência, visto que a memória entre os processos não são compartilhados, mas provê paralelismo.

Por exemplo, o seguinte código para encontrar um valor em um vetor:

```ruby
range = 0...10_000_000
number = 8_888_888

puts range.to_a.index(number)
```

Ao executar este código em um único processo/núcleo, este demorou em média 0m0.063s de sys para executar.

Dividindo em quatro processos, o código ficaria da seguinte maneira:

```ruby
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
```

Usando quatro processos/núcleo, este demorou em ḿédia 0m0.046s de sys para executar.

Entretanto, usar processos para execução paralela não é viável. Tanto por causa da falta de memória compartilhada, quanto pela não provisão de concorrência.

https://github.com/DanielVenturini/RubyConcorrent/blob/master/exemplos/process.rb

## Threads
O módulo mais básico para paralelismo em Ruby é o módulo ```Thread```. Uma thread pode ser criada APENAS chamando a função ```Thread.new```, que dispara uma thread:

```ruby
thr = Thread.new {
	[0,1,2,3,4,5,6,7,8,9].each do |pos|
		puts "Thread na posição #{pos}"
	end
}
```

Ao executar este bloco de código, deveria ser imprimido dez vezes a mensagem ```Thread na posição #{pos}```. Entretando isto não acontece, pois a thread que foi criada não chegou a ser executada. Quando a thread principal finaliza a execução, todas as threads que ainda estão executando serão terminadas. Por isso que as mensagens não foram exibidas, pois a thread principal encerrou antes desta segunda ser criada e executada, e consequentemente, encerrou esta também. Para contornar isto, pode ser usado a função ```join``` no objeto da Thread. Esta operação faz com que a thread principal - ou a thread que executar esta chamada - seja bloqueada até que a thread que está executando termine sua execução. O código acima pode ser reescrito da seguinte maneira:

```ruby
thr = Thread.new {
	[0,1,2,3,4,5,6,7,8,9].each do |pos|
		puts "Thread na posição #{pos}"
	end
}

thr.join
```

O Ruby retorna - implicitamente - o último valor assinalada em uma função, então podemos criar um vetor de Threads da seguinte maneira:

```ruby
def subvetor range
	
end

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
```

Para classes, o processo não é nem um pouco parecido com o do Java. Como a classe Thread possui um método chamado ```start```, é natural pensar que se inicia um classe com thread chamando o método ```start```. Porém, a herança em Ruby para a classe Thread não funciona como o esperado. Para conseguir executar um objeto com thread, é necessário realizar a mesma operação que nos exemplos passados:

```ruby
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

puts "Ligando os despertadores..."

t1 = Despertador.new(3, 'Roseta')
t2 = Despertador.new(5, 'Tomar')

t1 = t1.start t2
t2 = t2.start t1

puts "Despertadores ligados!"
t1.join
t2.join
```

Também, a classe ```Thread``` possúi outros atributos interessantes:

```ruby
Thread.exit 		# marca a thread para sair da execução. Se já foi marcada, sai imediatamente.
Thread.kill 		# termina a thread imediatamente.
Thread.alive?		# boleano representando se a thread está 'viva'
Thread.backtrace	# retorna o backtrace da thread
Thread.priority 	# prioridade da thread. As threads de maior prioridade será executado com mais frequencia do que threads de menor prioridade.
Thread.stop			# coloca a thread para o estado 'sleep'
Thread.run 			# coloca em execução uma thread que está no estado 'sleep'
Thread.status		# mostra o estado atual da thread: 'sleep', 'run', 'aborting', 'false', 'nil'
```

Pode ser necessária o uso da função ```Thread.current.#{def}```.

https://github.com/DanielVenturini/RubyConcorrent/blob/master/exemplos/thread.rb

## GIL vs JRuby - Condições de Corrida
O Ruby - assim como o Python - possúi o GIL - Global Interpreter Lock. Este tem por função fazer com que um determinado processo possua apenas uma Thread em execução em um determinado instante. Ou seja, o GIL provê exclusão mutua entre as threads. Isso significa que se um processo Ruby tiver, por exemplo, dez threads, somente uma estará em execução. Esta é a desvantagem do GIL, pois limita o paralelismo, mas provê a concorrência, pois os objetos compartilhados entre as threads serão acessados somente por uma thread por vez.

Sempre que é iniciado um script Ruby, uma instância de um interpretador Ruby é iniciada para analisar o código, construir uma árvore AST e executar o script - felizmente, tudo isso é transparente para o usuário. No entanto, como parte desse tempo de execução, o interpretador também instancia uma instância do GIL [Grigorik 2008]:

<p align="center">
	<img src="https://github.com/DanielVenturini/RubyConcorrent/blob/master/imagens/gilvsjruby.jpeg">
</p>

No Ruby 1.8, uma única thread do SO é alocado para o interpretador Ruby, o GIL é instanciado e as threads Ruby - Threads Verdes, ou seja, que são escalonadas por uma VM ao invés do SO - são armazenados em spool pelo programa. Não há como esse processo Ruby utilizar vários núcleos: existe apenas uma thread do kernel disponível, portanto, apenas um thread Ruby pode ser executado por vez.

O Ruby 1.9 tem muitas threads nativas anexados ao interpretador Ruby, mas agora o GIL é o gargalo. O intérprete é protegido contra código não-thread-safe, permitindo apenas que uma thread seja executado por vez. Efeito final: O processo Ruby MRI, ou qualquer outra linguagem que tenha um GIL (o Python, por exemplo, tem um modelo de encadeamento muito semelhante ao Ruby 1.9), nunca tirará vantagem de múltiplos núcleos!

O JRuby é a única implementação Ruby que permitirá dimensionar nativamente o código Ruby em vários núcleos. Ao compilar Ruby para bytecode e executá-lo na JVM, as threads Ruby são mapeados para threads do SO sem um GIL no meio.

Para entender melhor os efeitos, o seguinte código não-thread-safe é executado por apenas uma thread e transformado em thread-safe pelo GIL:

```ruby
count = 0
while count < 100 do

	soma = 0
	threads = []

	2.times {
		threads << Thread.new {
			(1..1000).each do |num|		# loop #1
				soma += num
			end
		}
	}

	threads.each {
		|thr| thr.join
	}

	count += 1
	puts "Resultado: #{soma}"
end
```

Como resultado do código acima, se executado com o Ruby, o resultado sempre será ```1001000```, pois somente uma thread executará por vez. Já se for executado com o JRuby, o resultado irá variar em algumas vezes, pois o JRuby não garante que o código seja executado em modo thread-safe.

Há também quem diga que o GIL não provê um código thread-safe [Storimer 2013].

### JRuby além do GIL
Outra grande vantagem de utilizar o ```JRuby``` é que este executa sobre a ```JVM```, permitindo assim interpretar tanto código ```Ruby``` quanto ```Java``` em um mesmo script [Nahum 2012].

A classe ```Semaphore``` não é nativa do ```Ruby```. Porém, pode ser usada a classe que está disponível na ```JVM```:

```ruby
java_import 'java.util.concurrent.Semaphore'
permits = 5

SEM = Semaphore.new(permits)

100.times do
	Thread.new {
		SEM.acquire
			puts "Estou na regiao critica com mais #{SEM.availablePermits}"
			sleep 0.5
		SEM.release
		puts "Sai da regiao critica"
	}
end
```

https://github.com/DanielVenturini/RubyConcorrent/blob/master/exemplos/giljruby.rb
https://github.com/DanielVenturini/RubyConcorrent/blob/master/exemplos/jruby.rb

## ThreadGroup
Quando várias threads são necessárias, uma possibilidade é manter todas em um grupo, para melhor gerência. A classe ```ThreadGroup``` dispôe de uma estrutura que comporta esta operação. Entretanto, uma thread só pode estar em apenas um grupo, assim, se um thread já estiver em outro grupo, esta será removida para ser adicionada no seu novo grupo. 

Quando uma thread é criada a partir de uma outra, a primeira será adicionada implicitamente no mesmo grupo.

```ruby
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

tg.add t1
tg.add t2
tg.add t3
```

Uma thread é adicionada ao grupo pela função ```add```ou explicitamente. Também, uma operação de "trava" pode ser usada no grupo, impedindo que outras threads possam ser adicionadas explicitamentes no grupo:

```ruby
tg.enclose
```

A partir desta linha de código, nenhuma thread pode ser adicionada no grupo. Nem mesmo as threads que são criadas a partir de threads daquele grupo.

A última operação disponível para o grupo de threads é a de retornar a lista de threads que estão neste grupo:
```ruby
ThreadGroup::Default.list
```

https://github.com/DanielVenturini/RubyConcorrent/blob/master/exemplos/threadgroup.rb

## Mutex e Monitor
Assim como nas demais linguagens que contém mecanismos de concorrências, o Ruby contém a classe ```Mutex```, que implementa um semáforo simples que pode ser usado para cordenar o acesso a dados compartilhados por múltiplas threads.

Um ```Mutex``` é criado chamando a função ```Mutex.new``` e todo a região critica é escrita dentro do bloco ```synchronize```, onde é provido exclusão mútua.

Um exemplo de região compartilhada é o seguinte trecho de código:

```ruby
$var1 = 0
$var2 = 0

def somaDecrementa
	# regiao critica
	$var1 += 1
	$var2 -= 1
end

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
```
Este código apenas atribui e decrementa nas variáveis globais ```var1``` e ```var2```. Executando com o ```ruby```, não haverá nenhum problema com a região crítica, visto que o GIL não permitirá mais de uma thread executando ao mesmo tempo. Porém, ao executar com o ```jruby```, o resultado é indefinido, pois as threads podem realizar a troca de contexto dentro da região crítica, assim ficando com valores incoerrentes.

Para resolver este problema, a região crítica pode ser inserida dentro de um bloco ```synchronize```, realizando assim, a exclusão mútua.

Então o código anterior que gera inconsistência - a função de região crítica -, é reescrito da seguinte maneira:

```ruby
$mutex = Mutex.new

def somaDecrementa
	$mutex.synchronize {
		# regiao critica com exclusão mútua
		$var1 += 1
		$var2 -= 1
	}
end
```

Agora, executando novamente com o ```jruby```, é provido sincronismo, e duas threads nunca estarão dentro do bloco ```synchronize``` em um determinado instante. E os valores resultantes são consistentes.

Junto com o ```synchronize```, pode ser usado a função ```lock``` e ```unlock```. A função ```lock``` bloqueia o mutex, e a ```unlock``` desbloqueia:

```ruby
def regiaoExclusiva
	puts "Tentando acessar o synchronize"
	$mutex.synchronize do
		puts "Conseguiu entrar no bloco synchronize"
		sleep 2
		puts "Saindo do synchronize"
	end
end

thr = Thread.new do
	regiaoExclusiva
end

if not $mutex.locked?
	puts "Nao está bloqueada ainda"
	$mutex.lock
	puts "Obteve o lock"
	sleep 2
	puts "Saindo do lock"
	$mutex.unlock
end

thr.join
```
A função ```Mutex.locked?``` apenas retorna true ou false para se o mutex já está bloqueado

A classe ```Monitor``` também fornece a exclusão mútua para um região crítica. Sua utilização se dá do mesmo modo que o ```Mutex```:

```ruby
lock = Monitor.new
lock.synchronize do
	# região crítica
end
```

A diferença dos monitores é que eles podem ser uma classe pai da classe corrente [Range 2017]. Ou seja, uma classe pode herdar da classe ```Monitor```. Entretanto, a classe ```Monitor``` só possui o método ```synchronize```, por isso não é tão utilizado quando o ```Mutex```, que possui mais métodos.

Ao usar ```Mutex```, pode ser utilizado outra estrutura para auxiliar em alguns problemas: ```ConditionVariable```. Estas, sinalizam quando um recurso está ocupado ou liberado, através de ```wait(mutex)``` e ```signal``` [Rangel 2017]:

```ruby
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

		cond.signal		# se fosse vários produtores: cond.broadcast
		end
	end
end

produtor.join
```

O produtor produz os items, avisa o consumidor que está tudo ok, o consumidor consome os items e sinaliza para o produtor que pode enviar mais.

## Referências

RUBY-DOC. Class: Thread (Ruby 2.5.3). Acessado em 18/11/2018. Disponível em https://ruby-doc.org/core-2.5.3/Thread.html

exAspArk. MEDIUM. Introduction to Concurrency Models with Ruby. Part I. Acessado em 02/12/2018. Disponível em https://engineering.universe.com/introduction-to-concurrency-models-with-ruby-part-i-550d0dbb970

Storimer J. RUBYINSIDE. Does the GIL Make Your Ruby Code Thread-Safe?. Acessado em 02/12/2018. Disponível em http://www.rubyinside.com/does-the-gil-make-your-ruby-code-thread-safe-6051.html

Grigorik I. IGVITA. Parallelism is a Myth in Ruby. Acessado em 02/12/2018. Disponível em https://www.igvita.com/2008/11/13/concurrency-is-a-myth-in-ruby/

Rangel E. Conhecendo Ruby. Aprenda de Forma Prática e Divertida. Leanpub, 2017.

Nahum D. PARACODE. Pragmatic Concorrency With Ruby. Acessado em 03/12/2018. Disponível em http://blog.paracode.com/2012/09/07/pragmatic-concurrency-with-ruby/