import React, { useState } from 'react';
import { BrowserRouter as Router, Routes, Route, Link } from 'react-router-dom';
import UserReport from './UserReport';
import ItemReport from './ItemReport';
import CartReport from './CartReport';
import OrderReport from './OrderReport'; 
import './AdminPanel.css';

function AdminPanel() {
  const [active, setActive] = useState('user-report');

  return (
    <Router>
      <div className="admin-panel">
        <nav className="side-nav">
          <ul>
            <li>
              <Link
                to="/user-report"
                className={active === 'user-report' ? 'active' : ''}
                onClick={() => setActive('user-report')}
              >
                User Report
              </Link>
            </li>
            <li>
              <Link
                to="/item-report"
                className={active === 'item-report' ? 'active' : ''}
                onClick={() => setActive('item-report')}
              >
                Item Report
              </Link>
            </li>
            <li>
              <Link
                to="/cart-report"
                className={active === 'cart-report' ? 'active' : ''}
                onClick={() => setActive('cart-report')}
              >
                Cart Report
              </Link>
            </li>
            <li>
              <Link
                to="/order-report"
                className={active === 'order-report' ? 'active' : ''}
                onClick={() => setActive('order-report')}
              >
                Order Report
              </Link>
            </li>
          </ul>
        </nav>
        <main className="main-content">
          <Routes>
            <Route path="/user-report" element={<UserReport />} />
            <Route path="/item-report" element={<ItemReport />} />
            <Route path="/cart-report" element={<CartReport />} />
            <Route path="/order-report" element={<OrderReport />} /> 
          </Routes>
        </main>
      </div>
    </Router>
  );
}

export default AdminPanel;
