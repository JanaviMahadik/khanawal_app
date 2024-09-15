import React, { useState, useEffect } from 'react';
import axios from 'axios';
import './CartReport.css';

function CartReport() {
  const [carts, setCarts] = useState([]);

  useEffect(() => {
    const fetchCarts = async () => {
      try {
        const response = await axios.get('http://localhost:3000/carts');
        setCarts(response.data);
      } catch (error) {
        console.error('Error fetching carts:', error);
      }
    };

    fetchCarts();
  }, []);

  return (
    <div className="cart-report">
      <h1>Cart Report</h1>
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
