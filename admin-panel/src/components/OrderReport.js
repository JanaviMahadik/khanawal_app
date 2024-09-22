import React, { useState, useEffect } from 'react';
import axios from 'axios';
import { BarChart, Bar, XAxis, YAxis, Tooltip, CartesianGrid, Legend } from 'recharts';
import './OrderReport.css';

function OrderReport() {
  const [orders, setOrders] = useState([]);
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const fetchOrders = async () => {
      try {
        const response = await axios.get('http://localhost:3000/orders');
        setOrders(response.data);
      } catch (error) {
        setError('Error fetching orders');
      } finally {
        setLoading(false);
      }
    };

    fetchOrders();
  }, []);

  const chartData = orders.map(order => ({
    name: order.itemName, 
    price: order.price, 
    serviceCharges: order.serviceCharges, 
  }));

  return (
    <div className="order-report">
      <h1>Order Report</h1>
      {loading && <p className="loading">Loading...</p>}
      {error && <p className="error">{error}</p>}

      <div className="chart-container">
        <BarChart width={600} height={400} data={chartData}>
          <CartesianGrid strokeDasharray="3 3" />
          <XAxis dataKey="name" />
          <YAxis />
          <Tooltip />
          <Legend />
          <Bar dataKey="price" fill="#82ca9d" />
          <Bar dataKey="serviceCharges" fill="#ffc658" />
        </BarChart>
      </div>

      <table className="order-report-table">
        <thead>
          <tr>
            <th>ID</th>
            <th>Item Name</th>
            <th>Price</th>
            <th>Service Charges</th>
            <th>Total Amount</th>
          </tr>
        </thead>
        <tbody>
          {orders.map((order) => (
            <tr key={order._id}>
              <td>{order.userId}</td>
              <td>{order.title}</td>
              <td>₹{order.price}</td>
              <td>₹{order.serviceCharges}</td>
              <td>₹{order.totalPrice}</td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}

export default OrderReport;
