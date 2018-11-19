thr = Thread.new { [0,1,2,3,4,5,6,7,8,9].each do |pos| puts "Thread na posição #{pos}" end }
thr.join