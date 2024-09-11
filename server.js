const express = require('express');
const mongoose = require('mongoose');
const app = express();
app.use(express.json());

mongoose.connect('mongodb+srv://janavi:passwords@cluster0.k2q6j.mongodb.net/khanawal?retryWrites=true&w=majority&appName=Cluster0', { useNewUrlParser: true, useUnifiedTopology: true });

mongoose.connection.on('connected', () => {
  console.log('Connected to MongoDB');
});

mongoose.connection.on('error', (err) => {
  console.log('MongoDB connection error:', err);
});

const userSchema = new mongoose.Schema({
  username: String,
  email: String,
  password: String,
  role: String,
}, { collection: 'users' });

const itemSchema = new mongoose.Schema({
    title: String,
    description: String,
    fileUrl: String,
    price: String,
    gst: Number,
    serviceCharges: Number,
    totalPrice: Number,
    //userId: mongoose.Schema.Types.ObjectId,
});

const orderSchema = new mongoose.Schema({
  userId: String,
  title: String,
  price: Number,
  gst: Number,
  serviceCharges: Number,
  totalPrice: Number,
  timestamp: { type: Date, default: Date.now }
});

const User = mongoose.model('User', userSchema);
const Item = mongoose.model('Item', itemSchema);
const Order = mongoose.model('Order', orderSchema);

app.post('/register', async (req, res) => {
  try {
    const user = new User(req.body);
    await user.save();
    res.status(201).send('User registered');
  } catch (error) {
    res.status(400).send('Error registering user');
  }
});

app.post('/addItem', async (req, res) => {
  const { title, description, fileUrl, price, gst, serviceCharges, totalPrice} = req.body;

  const newItem = new Item({
    title,
    description,
    fileUrl,
    price,
    gst,
    serviceCharges,
    totalPrice,
    //userId,
  });

  try {
    await newItem.save();
    res.status(201).send('Item saved to MongoDB');
  } catch (error) {
    res.status(500).send('Failed to save item to MongoDB');
  }
});

app.post('/addToCart', async (req, res) => {
  const { userId, title, price, gst, serviceCharges, totalPrice } = req.body;

  try {
    const cartItem = {
      userId,
      title,
      price,
      gst,
      serviceCharges,
      totalPrice,
      timestamp: new Date(),
    };

    await mongoose.connection.collection('carts').insertOne(cartItem);
    res.status(201).send('Item added to cart');
  } catch (error) {
    res.status(500).send('Failed to add item to cart');
  }
});

app.post('/placeOrder', async (req, res) => {
  try {
    const { userId, title, price, gst, serviceCharges, totalPrice } = req.body;

    const newOrder = new Order({
      userId,
      title,
      price,
      gst,
      serviceCharges,
      totalPrice
    });

    await newOrder.save();
    res.status(200).json({ message: 'Order placed successfully!' });
  } catch (error) {
    console.error('Error saving order:', error);
    res.status(500).json({ message: 'Failed to place order' });
  }
});

app.listen(3000, () => console.log('Server started on port 3000'));