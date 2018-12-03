require 'java'

def ex1
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
end





#ex1