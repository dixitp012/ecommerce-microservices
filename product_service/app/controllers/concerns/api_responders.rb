# frozen_string_literal: true

module ApiResponders
  extend ActiveSupport::Concern

  private
    def render_error(message, status = :unprocessable_entity, context = {})
      is_message_array = message.is_a?(Array)
      error_message = is_message_array ? message.to_sentence : message
      render status: Rack::Utils::SYMBOL_TO_STATUS_CODE[status], json: { error: error_message }.merge(context)
    end

    def render_message(message, status = :ok, context = {})
      render status: Rack::Utils::SYMBOL_TO_STATUS_CODE[status], json: { notice: message }.merge(context)
    end

    def render_json(json = {}, status = :ok)
      render status: Rack::Utils::SYMBOL_TO_STATUS_CODE[status], json:
    end

    def render_pagination_json(results, serializer, status = :ok)
      render status: Rack::Utils::SYMBOL_TO_STATUS_CODE[status], json: { results: ActiveModelSerializers::SerializableResource.new(results, each_serializer: serializer),
                              total_pages: results.total_pages,
                              current_page: results.current_page,
                              per_page: results.per_page,
                              total_entries: results.total_entries }
    end
end