import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:food_delivery_app/consts/cart_food.dart';
import 'package:food_delivery_app/screens/bottomNavBar.dart';


class Cart extends StatefulWidget {
  const Cart({Key? key}) : super(key: key);

  @override
  _CartState createState() => _CartState();
}

class _CartState extends State<Cart> {
  final DatabaseReference database = FirebaseDatabase.instance.ref();

  List<CartFood> cartFoodList = [];

  @override
  void initState() {
    super.initState();
    _activateListeners();
  }

  void _activateListeners() {
    database.child('cart').onValue.listen((event) {
      final map = event.snapshot.value as Map<dynamic, dynamic>;
      cartFoodList.clear();
      map.forEach((key, value) {
        var cartFood = CartFood.fromJson(json.decode(json.encode(value)));
        cartFood.key = key;
        cartFoodList.add(cartFood);
      });
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffF2F2F2),
      appBar: AppBar(
        toolbarHeight: 70.0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Home()),
            );
          },
        ),
        elevation: 0.0,
        centerTitle: true,
        title: Text(
          "Cart",
          style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 24,
              color: Colors.black.withOpacity(0.9)),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 10.0, bottom: 30.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image(image: AssetImage("lib/assets/swipeitem.png")),
                Text(
                  "swipe on an item to delete",
                  style: TextStyle(fontSize: 10),
                ),
              ],
            ),
            Expanded(
              child: Container(
                alignment: Alignment.center,
                child: ListView.builder(
                  itemCount: cartFoodList.length,
                  itemBuilder: (context, index) {
                    return _buildCartItem(cartFoodList[index]);
                  },
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                _showOrderConfirmationDialog();
              },
              child: Container(
                alignment: Alignment.center,
                height: 60,
                width: 300,
                decoration: BoxDecoration(
                  color: Color(0xffFA4A0C),
                  borderRadius: BorderRadius.circular(25.0),
                ),
                child: Text(
                  "Complete Order",
                  style: TextStyle(color: Colors.white, fontSize: 17),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartItem(CartFood cartFood) {
    return Container(
      margin: EdgeInsets.only(left: 30.0, right: 30.0, top: 30.0),
      child: Container(
        width: 315,
        height: 102,
        child: Slidable(
          endActionPane: ActionPane(
            motion: ScrollMotion(),
            children: [
              SlidableAction(
                backgroundColor: Colors.transparent,
                foregroundColor: Color(0xffDF2C2C),
                icon: Icons.favorite,
                onPressed: (context) {
                  _toggleFavorite(database, cartFood);
                  Navigator.pop(context); // Close the drawer first
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => Home()),
                  );
                },
              ),
              SlidableAction(
                backgroundColor: Colors.transparent,
                foregroundColor: Color(0xffDF2C2C),
                icon: Icons.delete,
                onPressed: (context) {
                  _deleteFromDatabase(database, cartFood);
                  Navigator.pop(context); // Close the drawer first
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => Home()),
                  );
                },
              ),
            ],
          ),
          child: Card(
            elevation: 0.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0),
            ),
            child: Stack(
              children: [
                Positioned(
                  left: 10,
                  top: 10,
                  child: Image(
                    image: AssetImage(cartFood.imagepath!),
                    height: 100,
                    width: 100,
                  ),
                ),
                Positioned(
                  left: 120,
                  top: 10,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          cartFood.name.toString(),
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 17,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          cartFood.price.toString(),
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 15,
                            color: Color(0xffFA4A0C),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  right: 20,
                  bottom: 10,
                  child: _buildItemPortion(cartFood),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildItemPortion(CartFood cartFood) {
    return Container(
      height: 25,
      width: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        color: Color(0xffFA4A0C),
      ),
      child: Stack(
        children: [
          Positioned(
            left: -10,
            top: -10,
            child: IconButton(
              color: Colors.white,
              iconSize: 15,
              splashRadius: 20,
              onPressed: () {
                _changePortion(false, database, cartFood);
              },
              icon: ImageIcon(AssetImage("lib/assets/-.png")),
            ),
          ),
          Positioned(
            top: 5,
            left: 25,
            child: Text(
              cartFood.count.toString(),
              style: TextStyle(fontSize: 14, color: Colors.white),
            ),
          ),
          Positioned(
            right: -10,
            top: -10,
            child: IconButton(
              color: Colors.white,
              iconSize: 15,
              splashRadius: 20,
              onPressed: () {
                _changePortion(true, database, cartFood);
              },
              icon: ImageIcon(AssetImage("lib/assets/+.png")),
            ),
          ),
        ],
      ),
    );
  }

  void _toggleFavorite(DatabaseReference database, CartFood cartFood) async {
    final favRef = database.child('favourites');
    final nextRef = <String, dynamic>{
      'name': cartFood.name,
      'price': cartFood.price,
      'imagepath': cartFood.imagepath,
    };
    String? key;
    database
        .child('favourites')
        .orderByChild('name')
        .equalTo(cartFood.name)
        .onChildAdded
        .listen((event) {
      setState(() {
        key = event.snapshot.key.toString();
      });
    }, onError: (Object o) {
      print(o.toString());
    });
    try {
      final value = await favRef.orderByChild('name').equalTo(cartFood.name).once();
      if (value.snapshot.exists) {
        if (key != null) {
          await database.child('favourites').child(key!).remove();
        }
      } else {
        await database.child('favourites').push().set(nextRef);
      }
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> _deleteFromDatabase(DatabaseReference database, CartFood cartFood) async {
    final ref = database.child('cart');
    String? key;
    database
        .child('cart')
        .orderByChild('name')
        .equalTo(cartFood.name)
        .onChildAdded
        .listen((event) {
      setState(() {
        key = event.snapshot.key.toString();
      });
    }, onError: (Object o) {
      print(o.toString());
    });

    try {
      final value = await ref.orderByChild('name').equalTo(cartFood.name).once();
      if (value.snapshot.exists) {
        if (key != null) {
          await database.child('cart').child(key!).remove();
        }
      }
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> _changePortion(bool increase, DatabaseReference database, CartFood? cartFood) async {
    final ref = database.child('cart');
    String? key;
    database
        .child('cart')
        .orderByChild('name')
        .equalTo(cartFood!.name)
        .onChildAdded
        .listen((event) {
      setState(() {
        key = event.snapshot.key.toString();
      });
    }, onError: (Object o) {
      print(o.toString());
    });

    try {
      final value = await ref.orderByChild('name').equalTo(cartFood.name).once();
      if (value.snapshot.exists) {
        if (increase) {
          if (key != null) {
            await database
                .child('cart')
                .child(key!)
                .child('count')
                .set(cartFood.count! + 1);
          }
        } else {
          if (value.snapshot.child(key!).child('count').value == 1) {
            await database.child('cart').child(key!).remove();
          } else {
            await database
                .child('cart')
                .child(key!)
                .child('count')
                .set(cartFood.count! - 1);
          }
        }
      }
    } catch (e) {
      print(e.toString());
    }
  }

  void _showOrderConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Thanks for your order!"),
        );
      },
    );

    Future.delayed(Duration(seconds: 5), () {
      Navigator.of(context).pop(); // Close the dialog
    });

    // Add code here to save the order to Firebase
    _saveOrderToFirebase();
  }

  Future<void> _saveOrderToFirebase() async {
    // Create a new order document with a unique ID
    final orderRef = database.child('orders').push();
    final orderId = orderRef.key; // Get the generated ID

    // Prepare order data as a map
    final orderData = {
      'orderId': orderId, // Include the order ID for reference
      'items': cartFoodList.map((cartItem) =>
      {
        'name': cartItem.name,
        'price': cartItem.price,
        'count': cartItem.count,
        // Add other properties as needed (e.g., image, category)
      }).toList(),
    };

    // Save the order data to Firebase
    try {
      await orderRef.set(orderData);
      print('Order saved successfully!');
    } catch (error) {
      print('Error saving order: $error');
      // Handle errors (optional: show a snackbar or dialog)
    }
  }


}



