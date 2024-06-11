# frozen_string_literal: true

class Api::V1::OrdersController < Api::V1::BaseController
  before_action :get_user, only: [:index, :create, :show, :update, :cancel]
  before_action :set_order, only: [:show, :update, :cancel]
  after_action :cleanup, only: [:create, :cancel]

  # GET /api/v1/orders
  def index
    if @user["error"]
      render json: { error: @user["error"] }, status: :unauthorized
    else
      @orders = Order.where(user_id: @user["id"])
      render json: @orders, include: "line_items"
    end
  end

  # GET /api/v1/orders/:id
  def show
    if @user["error"]
      render json: { error: @user["error"] }, status: :unauthorized
    else
      render json: @order, include: "line_items"
    end
  end

  # POST /api/v1/orders
  def create
    if @user["error"]
      render json: { error: @user["error"] }, status: :unauthorized
    else
      @order = Order.new(order_params.merge(user_id: @user["id"]))
      if stock_available?(@order.line_items)
        if @order.save
          @order.calculate_total_cost
          serialized_order = ActiveModelSerializers::SerializableResource.new(@order).as_json
          rabbitmq_service.publish_event("order.created", serialized_order)
          render json: serialized_order, status: :created
        else
          render json: @order.errors, status: :unprocessable_entity
        end
      else
        render json: { error: "Insufficient stock for one or more products" }, status: :unprocessable_entity
      end
    end
  end

  # PUT /api/v1/orders/:id
  def update
    if @user["error"]
      render json: { error: @user["error"] }, status: :unauthorized
    else
      if @order.update(order_params)
        @order.calculate_total_cost
        render json: @order, include: "line_items"
      else
        render json: @order.errors, status: :unprocessable_entity
      end
    end
  end

  # PUT /api/v1/orders/:id/cancel
  def cancel
    puts @user
    if @user["error"]
      render json: { error: @user["error"] }, status: :unauthorized
    else
      if @order.update(status: "canceled")
        serialized_order = ActiveModelSerializers::SerializableResource.new(@order).as_json
        rabbitmq_service.publish_event("order.canceled", serialized_order)
        render json: @order, include: "line_items"
      else
        render json: @order.errors, status: :unprocessable_entity
      end
    end
  end

  private

  def set_order
    @order = Order.find_by(id: params[:id], user_id: @user["id"])
    unless @order
      render json: { error: "Order not found or not authorized" }, status: :not_found
    end
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

  def stock_available?(line_items)
    line_items.all? do |line_item|
      stock_check_service = StockCheckService.new(line_item.product_id, line_item.quantity)
      stock_check_service.check_stock
    end
  end

  def get_user
    token = request.headers["Authorization"]&.split(" ")&.last
    @user = UserService.new.fetch_user(token)
    if @user["error"]
      render json: { error: @user["error"] }, status: :unauthorized
    end
  end
end
