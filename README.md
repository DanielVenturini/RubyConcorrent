# Programação Concorrente em Ruby

```Ruby``` é uma linguagem de programação interpretada, multiparadigma e fracamente tipada, desenvolvida em 1995 por Yukihiro Matsumoto. Inicialmente, seu projeto era para se tornar uma linguagem de script. A ídeia era criar uma liguagem mais poderosa que ```Perl``` e com mais orientação a objetos do que ```Python```.

<img align="left" src="https://github.com/DanielVenturini/RubyConcorrent/blob/master/imagens/logo.png">


Os mecanismos de concorrência, paralelismo e sincronização em Ruby são diversos e abrangentes; nativamente é provido desde simples ```Mutex``` até os mais variados tipos de ```Threads```, ```Barriers```, ```Poll```, etc. Suas interfaces e operações para programação concorrente e paralelismo se assimilham muito aos do Java. Além dos módulos nativos, pode ser encontrado várias outras implementações de paralelismo/concorrência/sincronização nas ```Gems``` do Ruby, que são implementações fornecidas pela comunidade.

Todos os códigos aqui apresentados foram executados com o ```Ruby 2.5.3```.

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

## Referências
exAspArk. MEDIUM. Introduction to Concurrency Models with Ruby. Part I. Acessado em 02/12/2018. Disponível em https://engineering.universe.com/introduction-to-concurrency-models-with-ruby-part-i-550d0dbb970

Storimer J. RUBYINSIDE. Does the GIL Make Your Ruby Code Thread-Safe?. Acessado em 02/12/2018. Disponível em http://www.rubyinside.com/does-the-gil-make-your-ruby-code-thread-safe-6051.html

Grigorik I. IGVITA. Parallelism is a Myth in Ruby. Acessado em 02/12/2018. Disponível em https://www.igvita.com/2008/11/13/concurrency-is-a-myth-in-ruby/