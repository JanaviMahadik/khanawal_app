import React, { useState, useEffect } from 'react';
import axios from 'axios';
import { PieChart, Pie, Cell, Tooltip, Legend } from 'recharts';
import './UserReport.css';

function UserReport() {
  const [users, setUsers] = useState([]);
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(true);
  const [newUser, setNewUser] = useState({
    username: '',
    email: '',
    password: '',
    role: 'customer',
  });

  useEffect(() => {
    const fetchUsers = async () => {
      try {
        const response = await axios.get('http://localhost:3000/users');
        setUsers(response.data);
      } catch (error) {
        setError('Error fetching users');
      } finally {
        setLoading(false);
      }
    };

    fetchUsers();
  }, []);

  const handleInputChange = (e) => {
    const { name, value } = e.target;
    setNewUser({ ...newUser, [name]: value });
  };

  const handleAddUser = async (e) => {
    e.preventDefault();
    try {
      await axios.post('http://localhost:3000/register', newUser);
      setUsers([...users, newUser]);
      setNewUser({
        username: '',
        email: '',
        password: '',
        role: 'customer',
      });
    } catch (error) {
      setError('Failed to register user');
    }
  };

  const deleteUser = async (userId) => {
    try {
      await axios.delete(`http://localhost:3000/deleteUser/${userId}`);
      setUsers(users.filter(user => user._id !== userId));
    } catch (error) {
      setError('Failed to delete user');
    }
  };

  const updateUserRole = async (userId, role) => {
    try {
      await axios.put(`http://localhost:3000/updateUserRole/${userId}`, { newRole: role });
      setUsers(users.map(user => user._id === userId ? { ...user, role } : user));
    } catch (error) {
      setError('Failed to update user role');
    }
  };

  const roleData = users.reduce((acc, user) => {
    const role = user.role;
    acc[role] = (acc[role] || 0) + 1;
    return acc;
  }, {});

  const chartData = Object.entries(roleData).map(([key, value]) => ({
    name: key,
    value: value,
  }));

  const COLORS = ['#0088FE', '#FFBB28', '#FF8042'];

  return (
    <div className="user-report">
      <h1>User Report</h1>
      {loading && <p className="loading">Loading...</p>}
      {error && <p className="error">{error}</p>}
      
      <form className="add-user-form" onSubmit={handleAddUser}>
        <h2>Add New User</h2>
        <input
          type="text"
          name="username"
          value={newUser.username}
          onChange={handleInputChange}
          placeholder="Username"
          required
        />
        <input
          type="email"
          name="email"
          value={newUser.email}
          onChange={handleInputChange}
          placeholder="Email"
          required
        />
        <input
          type="password"
          name="password"
          value={newUser.password}
          onChange={handleInputChange}
          placeholder="Password"
          required
        />
        <select
          name="role"
          value={newUser.role}
          onChange={handleInputChange}
        >
          <option value="customer">Customer</option>
          <option value="cook">Cook</option>
        </select>
        <button type="submit">Add User</button>
      </form>

      <PieChart width={400} height={400}>
        <Pie
          data={chartData}
          cx={200}
          cy={200}
          labelLine={false}
          label={entry => entry.name}
          outerRadius={80}
          fill="#8884d8"
          dataKey="value"
        >
          {chartData.map((entry, index) => (
            <Cell key={`cell-${index}`} fill={COLORS[index % COLORS.length]} />
          ))}
        </Pie>
        <Tooltip />
        <Legend />
      </PieChart>

      <table className="user-report-table">
        <thead>
          <tr>
            <th>Username</th>
            <th>Email</th>
            <th>Role</th>
            <th>Actions</th>
          </tr>
        </thead>
        <tbody>
          {users.map((user) => (
            <tr key={user._id}>
              <td>{user.username}</td>
              <td>{user.email}</td>
              <td>
                <select
                  value={user.role}
                  onChange={(e) => updateUserRole(user._id, e.target.value)}
                >
                  <option value="customer">Customer</option>
                  <option value="cook">Cook</option>
                </select>
              </td>
              <td>
                <button onClick={() => deleteUser(user._id)} className="delete-button">
                  Delete
                </button>
              </td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}

export default UserReport;
