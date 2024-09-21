import React, { useState, useEffect } from 'react';
import axios from 'axios';
import { BarChart, Bar, XAxis, YAxis, Tooltip, Legend, CartesianGrid } from 'recharts';
import './ItemReport.css';

function ItemReport() {
  const [items, setItems] = useState([]);
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const fetchItems = async () => {
      try {
        const response = await axios.get('http://localhost:3000/items');
        setItems(response.data);
      } catch (error) {
        setError('Error fetching items');
      } finally {
        setLoading(false);
      }
    };

    fetchItems();
  }, []);

  const chartData = items.map(item => ({
    name: item.title,
    price: item.price, 
  }));

  return (
    <div className="item-report">
      <h1>Item Report</h1>
      {loading && <p className="loading">Loading...</p>}
      {error && <p className="error">{error}</p>}

      <div className="chart-container">
        <BarChart width={600} height={400} data={chartData}>
          <CartesianGrid strokeDasharray="3 3" />
          <XAxis dataKey="name" />
          <YAxis />
          <Tooltip />
          <Legend />
          <Bar dataKey="price" fill="#8884d8" />
        </BarChart>
      </div>

      <table className="item-report-table">
        <thead>
          <tr>
            <th>Item Name</th>
            <th>Description</th>
            <th>Price</th>
          </tr>
        </thead>
        <tbody>
          {items.map((item) => (
            <tr key={item._id}>
              <td>{item.title}</td>
              <td>{item.description}</td>
              <td>${item.price}</td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}

export default ItemReport;
