class Consumer
  def initialize
    @connection = Bunny.new
  end

  def consume(queue_name)
    @connection.start
    channel = @connection.create_channel
    queue = channel.queue(queue_name)
    exchange = channel.fanout(queue_name)
    queue.bind(exchange)
    begin
      puts '[x x] waiting for message'
      queue.subscribe do |delivery_info, _properties, body|
        puts "[x] received #{body}"
      end
    rescue Interrupt => _
      @connection.close
    end
  end

end