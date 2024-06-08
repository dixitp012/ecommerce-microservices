class Api::V1::OrdersController < Api::V1::BaseController
  before_action :set_order, only: [:show, :update, :destroy]
  after_action :cleanup,  only: [:create]

  # GET /api/v1/orders
  def index
    @orders = Order.all
    render json: @orders, include: 'line_items'
  end

  # GET /api/v1/orders/:id
  def show
    render json: @order, include: 'line_items'
  end

  # POST /api/v1/orders
  def create
    @order = Order.new(order_params)

    if @order.save
      @order.calculate_total_cost
      serialized_order = ActiveModelSerializers::SerializableResource.new(@order).as_json
      rabbitmq_service.publish_event('order.created', serialized_order)
      render json: serialized_order, status: :created
    else
      render json: @order.errors, status: :unprocessable_entity
    end
  end

  # PUT /api/v1/orders/:id
  def update
    if @order.update(order_params)
      @order.calculate_total_cost
      render json: @order, include: 'line_items'
    else
      render json: @order.errors, status: :unprocessable_entity
    end
  end

  # DELETE /api/v1/orders/:id
  def destroy
    @order.destroy
    head :no_content
  end

  private

  def set_order
    @order = Order.find(params[:id])
  end

  def order_params
    params.require(:order).tap do |order_params|
      if order_params[:line_items_attributes]
        order_params[:line_items_attributes].each do |line_item|
          if line_item[:price]
            line_item[:price_cents] = (line_item[:price].to_f * 100).to_i
            line_item.delete(:price)
          end
        end
      end
    end.permit(:user_id, line_items_attributes: [:id, :product_id, :quantity, :price_cents, :_destroy])
  end

  def rabbitmq_service
    @rabbitmq_service ||= RabbitmqService.new
  end

  def cleanup
    @rabbitmq_service&.close
  end
end

