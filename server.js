const express = require('express');
const mongoose = require('mongoose');
const app = express();
app.use(express.json());

mongoose.connect('mongodb+srv://janavi:passwords@cluster0.k2q6j.mongodb.net/khanawal?retryWrites=true&w=majority&appName=Cluster0', { useNewUrlParser: true, useUnifiedTopology: true });

const userSchema = new mongoose.Schema({
  username: String,
  email: String,
  password: String,
  role: String,
}, { collection: 'app' });

const User = mongoose.model('User', userSchema);

app.post('/register', async (req, res) => {
  try {
    const user = new User(req.body);
    await user.save();
    res.status(201).send('User registered');
  } catch (error) {
    res.status(400).send('Error registering user');
  }
});

app.listen(3000, () => console.log('Server started on port 3000'));
