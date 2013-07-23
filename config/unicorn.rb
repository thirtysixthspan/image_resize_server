worker_processes 3

timeout 15
preload_app true

before_fork do |server, worker|
  Signal.trap 'TERM' do
    puts 'Unicorn master intercepting TERM and sending myself QUIT instead'
    Process.kill 'QUIT', Process.pid
  end
end 

after_fork do |server, worker|
  Signal.trap 'TERM' do
    puts 'Unicorn worker intercepting TERM and doing nothing. Wait for master to send QUIT'
  end
  $redis = Redis.new(:host => "127.0.0.1", :port => 6379)
  fail "No redis connection" unless $redis.ping == "PONG"
  $redis.select(1)  
end


