# Programação Concorrente em Ruby

```Ruby``` é uma linguagem de programação interpretada, multiparadigma e fracamente tipada, desenvolvida em 1995 por Yukihiro Matsumoto. Inicialmente, seu projeto era para se tornar uma linguagem de script. A ídeia era criar uma liguagem mais poderosa que ```Perl``` e com mais orientação a objetos do que ```Python```.

Os mecanismos de concorrência, paralelismo e sincronização em Ruby são diversos e abrangentes; nativamente é provido desde simples ```Mutex``` até os mais variados tipos de ```Threads``` e ```Barriers```. Suas interfaces e operações para programação concorrente e paralelismo se assimilham muito aos do Java. Além dos módulos nativos, pode ser encontrado várias outras implementações de paralelismo/concorrência/sincronização nas ```Gems``` do Ruby, que são implementações fornecidas pela comunidade.

Todos os códigos aqui apresentados foram executados com o ```Ruby 2.5.3```.

## Threads
O módulo mais básico para paralelismo em Ruby é o módulo ```Thread```. Uma thread pode ser criada APENAS chamando a função ```Thread.new```, que dispara uma thread:

```ruby
thr = Thread.new { [0,1,2,3,4,5,6,7,8,9].each do |pos| puts "Thread na posição #{pos}" end }
```

Ao executar este bloco de código, deveria ser imprimido dez vezes a mensagem ```Thread na posição #{pos}```. Entretando isto não acontece, pois a thread que foi criada não chegou a ser executada. Quando a thread principal finaliza a execução, todas as threads que ainda estão executando serão terminada. Por isso que as mensagens não foram exibidas, pois a thread principal encerrou antes desta segunda ser criada, e consequentemente, encerrou esta também. Para contornar isto, pode ser usado a função ```join``` no objeto da Thread. Esta operação faz com que a thread principal - ou a thread que executar esta chamada - seja bloqueada até que a thread que está executando termine sua execução. O código acima pode ser reescrito da seguinte maneira:

```ruby
thr = Thread.new { [0,1,2,3,4,5,6,7,8,9].each do |pos| puts "Thread na posição #{pos}" end }
thr.join
```