# frozen_string_literal: true

namespace :rabbitmq do
  desc "Start RabbitMQ consumer"
  task consume: :environment do
    rabbitmq_service = RabbitmqService.new

    rabbitmq_service.subscribe("order_queue") do |message|
      ProductUpdateJob.perform_async(message)
    end

    at_exit { rabbitmq_service.close }
  end
end
