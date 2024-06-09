
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
- **Auth Required**: Yes
- **Description**: Retrieve a specific product by ID.

#### Request Example:

```json
GET /api/v1/products/:id
Authorization: Bearer <your_token>
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
- **Auth Required**: Yes
- **Description**: Retrieve all products.

#### Request Example:

```json
GET /api/v1/products
Authorization: Bearer <your_token>
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

### Delete Order

- **URL**: `/api/v1/orders/:id`
- **Method**: `DELETE`
- **Auth Required**: Yes
- **Description**: Delete an existing order.

#### Request Example:

```json
DELETE /api/v1/orders/:id
Authorization: Bearer <your_token>
```