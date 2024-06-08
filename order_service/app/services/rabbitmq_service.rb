# rabbitmq_service.rb
class RabbitmqService
	def initialize
		@connection = Bunny.new(ENV['RABBITMQ_URL'])
		@connection.start
		@channel = @connection.create_channel
	end

	def message
		"Dixit"
	end

	def publish(queue_name, message)
		queue = @channel.queue(queue_name, durable: true)
		queue.publish(message, persistent: true)
	end

	def subscribe(queue_name, &block)
		queue = @channel.queue(queue_name, durable: true)
		queue.subscribe(manual_ack: true, block: true) do |delivery_info, _properties, body|
			begin
				block.call(body)
				@channel.ack(delivery_info.delivery_tag)
			rescue StandardError => e
				puts "Failed to process message: #{e.message}"
				@channel.nack(delivery_info.delivery_tag)
			end
		end
	end

	def publish_event(event_type, data, queue_name = 'order_queue')
		message = { event: event_type, data: data }.to_json
		publish(queue_name, message)
	end

	def close
		@connection.close
	end
end
