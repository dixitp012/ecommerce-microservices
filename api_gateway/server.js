const express = require('express');
const httpProxy = require("http-proxy");
const proxy = httpProxy.createProxyServer();
const morgan = require('morgan');

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(morgan('dev'));

proxy.on('proxyReq', (proxyReq, req, res, options) => {
  proxyReq.setTimeout(5000); // Increase the timeout to 5 seconds
});

// Proxy configuration
app.use("/auth", (req, res) => {
  proxy.web(req, res, { target: process.env.USER_AUTH_SERVICE_URL }, (err) => {
    console.error("Error connecting to user_auth_service:", err);
    res.status(502).send(`Bad Gateway${err}`);
  });
});

// Route requests to the product service
app.use("/api/v1/products", (req, res) => {
  const targetUrl = `${process.env.PRODUCT_SERVICE_URL}/api/v1/products`;

  proxy.web(req, res, { target: targetUrl }, (err) => {
    console.error("Error connecting to product_service:", err);
    res.status(502).send("Bad Gateway");
  });
});

// Route requests to the order service
app.use("/api/v1/orders", (req, res) => {
  const targetUrl = `${process.env.ORDER_SERVICE_URL}/api/v1/orders`;
  proxy.web(req, res, { target: targetUrl }, (err) => {
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
