# frozen_string_literal: true

class RabbitmqService
  def initialize
    @connection = Bunny.new(ENV["RABBITMQ_URL"])
    @connection.start
    @channel = @connection.create_channel
  end

  def publish(queue_name, message)
    queue = @channel.queue(queue_name, durable: true)
    queue.publish(message, persistent: true)
  end

  def subscribe(queue_name, &block)
    queue = @channel.queue(queue_name, durable: true)
    queue.subscribe(manual_ack: true, block: true) do |delivery_info, _properties, body|
      block.call(body)
      @channel.ack(delivery_info.delivery_tag)
    rescue StandardError => e
      puts "Failed to process message: #{e.message}"
      @channel.nack(delivery_info.delivery_tag)
    end
  end

  def publish_event(event_type, data, queue_name = "order_queue")
    message = { event: event_type, data: }.to_json
    publish(queue_name, message)
  end

  def close
    @connection.close
  end
end
