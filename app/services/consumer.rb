class Consumer
  class << self
    def consume(queue_name)
      queue = channel.queue(queue_name, durable: true)
      # exchange = channel.fanout(queue_name)
      exchange = channel.direct("direct_exchange")
      queue.bind(exchange, routing_key: "direct_route")
      begin
        puts '[x x] waiting for message'
        puts "[x] Counting" + queue.message_count.to_s
        queue.subscribe manual_ack: true do |delivery_info, _properties, body|
          puts "[x] received #{body}"
          body = JSON.parse!(body)
          Post.create!(body)
          channel.ack(delivery_info.delivery_tag )
        end
      rescue Interrupt => _
        @connection.close
      end
    end

      def channel
        @channel ||= connection.create_channel
      end

      def connection
        @connection ||= Bunny.new.start
      end
    end

end