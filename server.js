const express = require('express');
const mongoose = require('mongoose');
const app = express();
app.use(express.json());
const cors = require('cors');
app.use(cors());
const { ObjectId } = mongoose.Types;

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
  });

  try {
    const savedItem = await newItem.save();
    
    res.status(201).send({ message: 'Item saved to MongoDB', mongoId: savedItem._id });
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

app.put('/updateUsername', async (req, res) => {
  const { email, newUsername } = req.body;

  try {
    const user = await User.findOneAndUpdate(
      { email: email },
      { $set: { username: newUsername } },
      { new: true }
    );

    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }

    res.status(200).json({ message: 'Username updated successfully', user });
  } catch (error) {
    console.error('Error updating username:', error);
    res.status(500).json({ message: 'Failed to update username' });
  }
});

app.put('/updateUserRole/:id', async (req, res) => {
  const { id } = req.params;
  const { newRole } = req.body;

  try {
    const user = await User.findByIdAndUpdate(id, { role: newRole }, { new: true });

    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }

    res.status(200).json({ message: 'User role updated successfully', user });
  } catch (error) {
    console.error('Error updating user role:', error);
    res.status(500).json({ message: 'Failed to update user role' });
  }
});

app.get('/users', async (req, res) => {
  try {
    const users = await User.find();
    res.status(200).json(users);
  } catch (error) {
    res.status(500).json({ message: 'Failed to fetch users' });
  }
});

app.get('/items', async (req, res) => {
  try {
    const items = await Item.find(); 
    res.status(200).json(items);
  } catch (error) {
    res.status(500).json({ message: 'Failed to fetch items' });
  }
});

app.get('/carts', async (req, res) => {
  try {
    const carts = await mongoose.connection.collection('carts').find().toArray();
    res.status(200).json(carts);
  } catch (error) {
    console.error('Error fetching carts:', error);
    res.status(500).json({ message: 'Failed to fetch carts' });
  }
});

app.get('/orders', async (req, res) => {
  try {
    const orders = await Order.find(); 
    res.status(200).json(orders);
  } catch (error) {
    console.error('Error fetching orders:', error);
    res.status(500).json({ message: 'Failed to fetch orders' });
  }
});

app.delete('/deleteUser/:id', async (req, res) => {
  try {
    const userId = req.params.id;

    const result = await User.findByIdAndDelete(userId);

    if (!result) {
      return res.status(404).json({ message: 'User not found' });
    }

    res.status(200).json({ message: 'User deleted successfully' });
  } catch (error) {
    console.error('Error deleting user:', error);
    res.status(500).json({ message: 'Server error' });
  }
});

app.delete('/deleteItem/:id', async (req, res) => {
  const { id } = req.params;

  if (!ObjectId.isValid(id)) {
    return res.status(400).json({ message: 'Invalid ObjectId format' });
  }

  try {
    console.log("Attempting to delete item with ID:", id);
    const deletedItem = await Item.findByIdAndDelete(id);

    if (!deletedItem) {
      return res.status(404).json({ message: 'Item not found' });
    }

    res.status(200).json({ message: 'Item deleted successfully', deletedItem });
  } catch (error) {
    console.error('Error deleting item:', error);
    res.status(500).json({ message: 'Failed to delete item' });
  }
});


app.listen(3000, () => console.log('Server started on port 3000'));