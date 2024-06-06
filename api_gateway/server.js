const express = require('express');
const httpProxy = require("http-proxy");

const proxy = httpProxy.createProxyServer();
const morgan = require('morgan');

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(morgan('dev'));

// Proxy configuration
app.use("/auth", (req, res) => {
  proxy.web(req, res, { target: process.env.USER_AUTH_SERVICE_URL }, (err) => {
    console.error("Error connecting to user_auth_service:", err);
    res.status(502).send(`Bad Gateway${err}`);
  });
});

// Route requests to the product service
app.use("/products", (req, res) => {
  proxy.web(req, res, { target: process.env.PRODUCT_SERVICE_URL }, (err) => {
    console.error("Error connecting to product_service:", err);
    res.status(502).send("Bad Gateway");
  });
});

// Route requests to the order service
app.use("/orders", (req, res) => {
  proxy.web(req, res, { target: process.env.ORDER_SERVICE_URL }, (err) => {
    console.error("Error connecting to order_service:", err);
    res.status(502).send("Bad Gateway");
  });
});

app.get('/up', (req, res) => {
  res.status(200).send("API Gateway is up and running");
});

app.listen(PORT, () => {
  console.log(`API Gateway running on port ${PORT}`);
});
