import React, { useState, useEffect } from 'react';
import axios from 'axios';
import './OrderReport.css'; 

function OrderReport() {
  const [orders, setOrders] = useState([]);

  useEffect(() => {
    const fetchOrders = async () => {
      try {
        const response = await axios.get('http://localhost:3000/orders');
        setOrders(response.data);
      } catch (error) {
        console.error('Error fetching orders:', error);
      }
    };

    fetchOrders();
  }, []);

  return (
    <div className="order-report">
      <h1>Order Report</h1>
      <table className="order-report-table">
        <thead>
          <tr>
            <th>User ID</th>
            <th>Item Name</th>
            <th>Price</th>
            <th>GST</th>
            <th>Service Charges</th>
            <th>Total Price</th>
            <th>Timestamp</th>
          </tr>
        </thead>
        <tbody>
          {orders.map((order) => (
            <tr key={order._id}>
              <td>{order.userId}</td>
              <td>{order.title}</td>
              <td>${order.price}</td>
              <td>${order.gst}</td>
              <td>${order.serviceCharges}</td>
              <td>${order.totalPrice}</td>
              <td>{new Date(order.timestamp).toLocaleString()}</td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}

export default OrderReport;
