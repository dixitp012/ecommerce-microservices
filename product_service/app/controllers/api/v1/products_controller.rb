# frozen_string_literal: true

class Api::V1::ProductsController < Api::V1::BaseController
  before_action :set_product, only: [:show, :update, :destroy, :add_stock, :available_stock]

  # GET /api/v1/products
  def index
    @products = Product.all
    render_json @products
  end

  # GET /api/v1/products/:id
  def show
    render_json @product
  end

  # POST /api/v1/products
  def create
    @product = Product.new(product_params)

    if @product.save
      render_json @product
    else
      render_error @product.errors.full_messages
    end
  end

  # PATCH/PUT /api/v1/products/:id
  def update
    retries = 3
    begin
      Product.transaction do
        @product = Product.lock.find(params[:id])
        if @product.update(product_params)
          render_json @product
        else
          render_error @product.errors.full_messages
        end
      end
    rescue ActiveRecord::StaleObjectError
      retries -= 1
      if retries > 0
        sleep(0.1) # Short delay before retrying
        retry
      else
        render_error "Product update failed due to a concurrent edit. Please try again.", :conflict
      end
    end
  end

  # DELETE /api/v1/products/:id
  def destroy
    @product.destroy
    head :no_content
  end

  # POST /api/v1/products/:id/add_stock
  def add_stock
    stock = params[:stock].to_i

    if stock <= 0
      render json: { error: "Stock must be greater than 0" }, status: :unprocessable_entity
      return
    end

    new_stock = @product.stock + stock
    if @product.update(stock: new_stock)
      render json: @product, status: :ok
    else
      render json: @product.errors, status: :unprocessable_entity
    end
  end

  # GET /api/v1/products/:id/available_stock
  def available_stock
    render json: { stock: @product.available_stock }, status: :ok
  end

  private
    def set_product
      @product = Product.find(params[:id])
    end

    def product_params
      permitted = params.require(:product).permit(:name, :description, :stock, :price, :currency, :active)

      if permitted[:price].present?
        permitted[:price_cents] = (permitted[:price].to_f * 100).to_i
        permitted.delete(:price)
      end
      permitted
    end
end
