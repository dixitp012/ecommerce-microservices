# frozen_string_literal: true

namespace :rabbitmq do
  desc "Start RabbitMQ consumer"
  task consume: :environment do
    begin
      rabbitmq_service = RabbitmqService.new

      rabbitmq_service.subscribe("order_queue") do |message|
        Rails.logger.info "Received message: #{message}"
        ProductUpdateJob.perform_async(message)
        Rails.logger.info "Enqueued ProductUpdateJob for message: #{message}"
      end

      at_exit { rabbitmq_service.close }
    rescue Bunny::HostListDepleted => e
      Rails.logger.error "RabbitMQ connection failed: #{e.message}"
      Rails.logger.info "Retrying RabbitMQ connection in 5 seconds"
      sleep 5
      retry
    rescue => e
      Rails.logger.error "An unexpected error occurred: #{e.message}"
      raise
    end
  end
end
