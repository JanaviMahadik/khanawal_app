import React, { useState, useEffect } from 'react';
import axios from 'axios';
import { LineChart, Line, XAxis, YAxis, Tooltip, CartesianGrid, Legend } from 'recharts';
import './CartReport.css';

function CartReport() {
  const [carts, setCarts] = useState([]);
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const fetchCarts = async () => {
      try {
        const response = await axios.get('http://localhost:3000/carts');
        setCarts(response.data);
      } catch (error) {
        setError('Error fetching carts');
      } finally {
        setLoading(false);
      }
    };

    fetchCarts();
  }, []);

  const chartData = carts.map(cartItem => ({
    name: cartItem.title,
    totalPrice: cartItem.totalPrice,
  }));

  return (
    <div className="cart-report">
      <h1>Cart Report</h1>
      {loading && <p className="loading">Loading...</p>}
      {error && <p className="error">{error}</p>}

      <div className="chart-container">
        <LineChart width={600} height={300} data={chartData}>
          <CartesianGrid strokeDasharray="3 3" />
          <XAxis dataKey="name" />
          <YAxis />
          <Tooltip />
          <Legend />
          <Line type="monotone" dataKey="totalPrice" stroke="#8884d8" activeDot={{ r: 8 }} />
        </LineChart>
      </div>

      <table className="cart-report-table">
        <thead>
          <tr>
            <th>Item Name</th>
            <th>Price</th>
            <th>GST</th>
            <th>Service Charges</th>
            <th>Total Price</th>
          </tr>
        </thead>
        <tbody>
          {carts.map((cartItem) => (
            <tr key={cartItem._id}>
              <td>{cartItem.title}</td>
              <td>${cartItem.price}</td>
              <td>${cartItem.gst}</td>
              <td>${cartItem.serviceCharges}</td>
              <td>${cartItem.totalPrice}</td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}

export default CartReport;
