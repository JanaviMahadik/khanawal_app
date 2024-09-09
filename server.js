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

const User = mongoose.model('User', userSchema);
const Item = mongoose.model('Item', itemSchema);

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
  const { title, description, fileUrl, price, gst, serviceCharges, totalPrice } = req.body;

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

app.listen(3000, () => console.log('Server started on port 3000'));
