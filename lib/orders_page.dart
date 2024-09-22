import 'package:flutter/material.dart';
import 'package:snippet_coder_utils/hex_color.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class OrdersPage extends StatefulWidget {
  const OrdersPage({Key? key}) : super(key: key);

  @override
  _OrdersPageState createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  int _currentIndex = 1;
  List<dynamic> orders = [];
  int _orderCount = 0;

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });

    if (index == 0) {
      Navigator.pushReplacementNamed(context, '/cook_home');
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    final url = 'http://192.168.31.174:3000/orders';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final allOrders = jsonDecode(response.body);
        setState(() {
          orders = allOrders.where((order) =>
          order['status'] != 'accepted' && order['status'] != 'declined').toList();
          _orderCount = orders.length;
        });
      } else {
        throw Exception('Failed to load orders');
      }
    } catch (e) {
      print('Error fetching orders: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching orders')),
      );
    }
  }

  Future<void> _updateOrderStatus(String orderId, String status) async {
    final url = 'http://192.168.31.174:3000/updateOrder/$orderId';

    try {
      final response = await http.put(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({'status': status}),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Order $status')),
        );
        _fetchOrders();
      } else {
        throw Exception('Failed to update order status');
      }
    } catch (e) {
      print('Error updating order status: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating order status')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Orders'),
        backgroundColor: HexColor("#283B71"),
      ),
      body: orders.isEmpty
          ? Center(
        child: Text(
          'No orders placed yet',
          style: TextStyle(fontSize: 18),
        ),
      )
          : ListView.builder(
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final order = orders[index];
          return ListTile(
            title: Text(order['title'] ?? 'No Title'),
            subtitle: Text(
              'Price: ₹${order['price']}\n'
                  'GST: ₹${order['gst']}\n'
                  'Service Charges: ₹${order['serviceCharges']}\n'
                  'Total: ₹${order['totalPrice']}',
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.check, color: Colors.green),
                  onPressed: () => _updateOrderStatus(order['_id'], 'accepted'),
                ),
                IconButton(
                  icon: Icon(Icons.close, color: Colors.red),
                  onPressed: () => _updateOrderStatus(order['_id'], 'declined'),
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home Page',
          ),
          BottomNavigationBarItem(
            icon: Stack(
              children: [
                Icon(Icons.receipt_long),
                if (_orderCount > 0)
                  Positioned(
                    right: 0,
                    child: Container(
                      padding: EdgeInsets.all(1.0),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(6.0),
                      ),
                      constraints: BoxConstraints(
                        minWidth: 12.0,
                        minHeight: 12.0,
                      ),
                      child: Center(
                        child: Text(
                          '$_orderCount',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 8.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            label: 'Orders',
          ),
        ],
      ),
    );
  }
}