require 'java'

java_import 'java.util.concurrent.Semaphore'

SEM = Semaphore.new(4)
SEM.acquire #To decrement the number available
SEM.release #To increment the number available