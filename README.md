# E-commerce Microservices Setup

This project consists of multiple microservices for an e-commerce application, including user authentication, product management, order management, an API gateway, and Nginx. The services use Docker and Docker Compose for containerization and orchestration.

## Prerequisites

- Docker: [Install Docker](https://docs.docker.com/get-docker/)
- Docker Compose: [Install Docker Compose](https://docs.docker.com/compose/install/)

## Project Structure

```
ecommerce-microservices/
├── user_auth_service/
├── product_service/
├── order_service/
├── api_gateway/
├── nginx/
├── docker-compose.yml
└── README.md
```

## Services

- **db**: PostgreSQL database
- **rabbitmq**: RabbitMQ message broker
- **sidekiq**: Sidekiq for background job
- **user_auth_service**: User authentication service
- **product_service**: Product management service
- **order_service**: Order management service
- **api_gateway**: API gateway for routing requests
- **nginx**: Nginx server for load balancing

## Setup Instructions

1. **Clone the repository:**

    ```bash
    git clone https://github.com/yourusername/ecommerce-microservices.git
    cd ecommerce-microservices
    ```

2. **Build, start the services and database (create & migration):**

    ```bash
    docker-compose up --build
    ```

    ```bash
    # Run the following commands only if setting up the databases for the first time:

    docker-compose exec user_auth_service bundle exec rails db:create db:migrate
    docker-compose exec product_service bundle exec rails db:create db:migrate
    docker-compose exec order_service bundle exec rails db:create db:migrate
    ```

    **If `rabbitmq` and `redis` images are not pulled with `docker-compose up --build`, pull them manually:**

    ```bash
    docker pull rabbitmq:3.6-management-alpine
    docker pull redis:alpine
    ```

3. **Generate the `USER_AUTH_SERVICE_TOKEN`:**

    To communicate between microservices, generate the authentication token by running the following command:

    ```bash
    docker-compose exec user_auth_service bundle exec rake token:generate
    ```

    This command will generate a token. Note this token for the next step.

4. **Update `docker-compose.yml` with the generated token:**

    Open the `docker-compose.yml` file and update the `USER_AUTH_SERVICE_TOKEN` environment variable for the services with the generated token.

    ```yaml
    environment:
      - USER_AUTH_SERVICE_TOKEN=your_generated_token
    ```

5. **Restart the services to apply the changes:**

    ```bash
    docker-compose down
    docker-compose up --build
    ```

6. **Accessing the services:**

    All endpoints should be accessed using the API Gateway base URL (`http://localhost:3000`) instead of the specific service URLs.

    - **API Gateway**: http://localhost:3000
    - **User Authentication Service**: http://localhost:3001
    - **Product Service**: http://localhost:3002
    - **Order Service**: http://localhost:3003
    - **Nginx**: http://localhost

## Environment Variables

The services require certain environment variables to be set. These are configured in the `docker-compose.yml` file.

- **db**:
  - `POSTGRES_PASSWORD`: Password for PostgreSQL.

- **rabbitmq**:
  - `AMQP_URL`: URL for RabbitMQ.
  - `RABBITMQ_DEFAULT_USER`: Default username for RabbitMQ.
  - `RABBITMQ_DEFAULT_PASS`: Default password for RabbitMQ.

- **redis**:
  - No environment variables required.

- **user_auth_service**, **product_service**, **order_service**, **api_gateway**:
  - `RAILS_ENV`: Rails environment (development).
  - `RABBITMQ_URL`: URL for RabbitMQ.
  - `REDIS_URL`: URL for Redis.
  - `USER_AUTH_SERVICE_URL`: URL for User Authentication Service.
  - `USER_AUTH_SERVICE_TOKEN`: Token for User Authentication Service (to be generated and updated as described above).
  - `PRODUCT_SERVICE_URL`: URL for Product Service.
  - `ORDER_SERVICE_URL`: URL for Order Service.

## Dependencies

Each service may have its own dependencies and setup instructions. Refer to the `README.md` file within each service's directory for more details.

## Data Persistence

PostgreSQL data is persisted in a Docker volume named `postgres_data`.

## Network

All services are connected via a Docker network named `my_network`.

## Troubleshooting

- If you encounter issues with services not starting, check the Docker logs for error messages:

    ```bash
    docker-compose logs
    ```

- Ensure that no other services are running on the same ports (3000-3003, 5432, 5672, 15672, 6379, 80).

## Stopping the Services

To stop the services, run:

```bash
docker-compose down
```

## Cleanup

To remove all containers, networks, and volumes, run:

```bash
docker-compose down -v
```

# E-commerce Microservice API Documentation

This document provides an overview of the e-commerce microservice API endpoints for managing orders, products, and user authentication.

## API Gateway

#### Base URL

- API Gateway Service: `http://localhost:3000`

All endpoints should be accessed using the API Gateway base URL (`http://localhost:3000`) instead of the specific service URLs.

## Authentication

All endpoints require a Bearer token for authentication. Ensure to include the token in the request headers.

```json
Authorization: Bearer <your_token>
```

## User Authentication Service

#### Base URL

- User Authentication Service: `http://localhost:3001`

### Create User

- **URL**: `/users`
- **Method**: `POST`
- **Auth Required**: No
- **Description**: Create a new user.

#### Request Example:

```json
POST /users
{
  "user": {
    "email": "test@example.com",
    "password": "password",
    "password_confirmation": "password"
  }
}
```

### Login

- **URL**: `/auth/login`
- **Method**: `POST`
- **Auth Required**: No
- **Description**: Login and receive an authentication token.

#### Request Example:

```json
POST /auth/login
{
  "email": "test@example.com",
  "password": "password"
}
```

## Product Service

#### Base URL

- Product Service: `http://localhost:3002`

### Get Product by ID

- **URL**: `/api/v1/products/:id`
- **Method**: `GET`
- **Auth Required**: No
- **Description**: Retrieve a specific product by ID.

#### Request Example:

```json
GET /api/v1/products/:id
```

### Create Product

- **URL**: `/api/v1/products`
- **Method**: `POST`
- **Auth Required**: Yes
- **Description**: Create a new product.

#### Request Example:

```json
POST /api/v1/products
Authorization: Bearer <your_token>
{
  "product": {
    "name": "Sample Product 1",
    "description": "This is a description of the sample product.",
    "price": 100,
    "currency": "USD",
    "active": true,
    "stock": 10
  }
}
```

### Get All Products

- **URL**: `/api/v1/products`
- **Method**: `GET`
- **Auth Required**: No
- **Description**: Retrieve all products.

#### Request Example:

```json
GET /api/v1/products
```

### Update Product

- **URL**: `/api/v1/products/:id`
- **Method**: `PUT`
- **Auth Required**: Yes
- **Description**: Update an existing product.

#### Request Example:

```json
PUT /api/v1/products/:id
Authorization: Bearer <your_token>
{
  "product": {
    "name": "Sample Product 2",
    "description": "This is a description of the sample product.",
    "price": 120,
    "currency": "USD",
    "active": true,
    "stock": 10
  }
}
```

### Delete Product

- **URL**: `/api/v1/products/:id`
- **Method**: `DELETE`
- **Auth Required**: Yes
- **Description**: Delete an existing product.

#### Request Example:

```json
DELETE /api/v1/products/:id
Authorization: Bearer <your_token>
```

### Add Stock

- **URL**: `/api/v1/products/:id/add_stock`
- **Method**: `POST`
- **Auth Required**: Yes
- **Description**: Add stock to an existing product.

#### Request Example:

```json
POST /api/v1/products/:id/add_stock
Authorization: Bearer <your_token>
{
  "stock": 5
}
```

### Check Available Stock (This endpoint is used by Order Service & Product Service internally)

- **URL**: `/api/v1/products/:id/available_stock`
- **Method**: `GET`
- **Auth Required**: Yes
- **Description**: Check available stock for a product.

#### Request Example:

```json
GET /api/v1/products/:id/available_stock
Authorization: Bearer <your_token>
```

## Order Service

#### Base URL

- Order Service: `http://localhost:3003`

### Get All Orders

- **URL**: `/api/v1/orders`
- **Method**: `GET`
- **Auth Required**: Yes
- **Description**: Retrieve all orders.

#### Request Example:

```json
GET /api/v1/orders
Authorization: Bearer <your_token>
```

### Get Order by ID

- **URL**: `/api/v1/orders/:id`
- **Method**: `GET`
- **Auth Required**: Yes
- **Description**: Retrieve a specific order by ID.

#### Request Example:

```json
GET /api/v1/orders/:id
Authorization: Bearer <your_token>
```

### Create Order

- **URL**: `/api/v1/orders`
- **Method**: `POST`
- **Auth Required**: Yes
- **Description**: Create a new order.

#### Request Example:

```json
POST /api/v1/orders
Authorization: Bearer <your_token>
{
  "order": {
    "user_id": "074f9ab9-8160-43f5-a696-5028d348a604",
    "line_items_attributes": [
      {
        "product_id": "9f64c042-088e-4c6b-80cf-4d7470322242",
        "quantity": 1,
        "price": 150
      }
    ]
  }
}
```

### Update Order

- **URL**: `/api/v1/orders/:id`
- **Method**: `PUT`
- **Auth Required**: Yes
- **Description**: Update an existing order.

#### Request Example:

```json
PUT /api/v1/orders/:id
Authorization: Bearer <your_token>
{
  "order": {
    "line_items_attributes": [
      {
        "product_id": "9f64c042-088e-4c6b-80cf-4d7470322242",
        "quantity": 2,
        "price": 150
      }
    ]
  }
}
```

### Cancel Order

- **URL**: `/api/v1/orders/:id/cancel`
- **Method**: `PUT`
- **Auth Required**: Yes
- **Description**: Cancel an existing order.

#### Request Example:

```json
PUT /api/v1/orders/:id/cancel
Authorization: Bearer <your_token>
```