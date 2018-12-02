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

# ruby giljruby.rb: 1001000
# ruby giljruby.rb: indefinido