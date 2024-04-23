import 'package:flutter/material.dart';
import 'login.dart'; // Importing login.dart

void main() {
  runApp(EcommerceApp());
}

class EcommerceApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        backgroundColor:
            Colors.white, // changed primaryColor to backgroundColor
        scaffoldBackgroundColor: Colors.white,
        colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.blue)
            .copyWith(secondary: Colors.red),
      ),
      home: LoginPage(), // Entry point is LoginPage
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? selectedFilter;
  String? searchString = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Expanded(
              child: Text('Shoe Buying App'),
            ),
            IconButton(
              icon: Icon(Icons.search),
              onPressed: () {
                showSearch(
                  context: context,
                  delegate: ShoeSearchDelegate(),
                );
              },
            ),
            IconButton(
              icon: Icon(Icons.filter_alt),
              onPressed: () {
                _showFilterOptions(context);
              },
            ),
          ],
        ),
      ),
      body: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 8.0,
          crossAxisSpacing: 8.0,
          childAspectRatio: 0.7,
        ),
        itemCount: shoes.length,
        itemBuilder: (context, index) {
          if (searchString!.isNotEmpty) {
            final shoe = shoes[index];
            final nameMatches =
                shoe.name.toLowerCase().contains(searchString!.toLowerCase());
            final priceMatches = shoe.price.toString().contains(searchString!);
            if (!nameMatches && !priceMatches) {
              return Container();
            }
          }
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ShoeDetailPage(shoe: shoes[index]),
                ),
              );
            },
            child: AnimatedScaleOnHover(
              scale: 1.02,
              child: Card(
                elevation: 4.0,
                color: Colors.white.withOpacity(0.7),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Expanded(
                      child: Stack(
                        alignment: Alignment.topRight,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(10.0),
                                topRight: Radius.circular(10.0),
                              ),
                              image: DecorationImage(
                                image: NetworkImage(shoes[index].imageUrl),
                                fit: BoxFit.fill,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.favorite),
                            color: (shoes[index].isFavorite)
                                ? Colors.red
                                : Colors.grey,
                            onPressed: () {
                              // Toggle favorite status
                              setState(() {
                                shoes[index].isFavorite =
                                    !shoes[index].isFavorite;
                                if (shoes[index].isFavorite) {
                                  favorites.add(shoes[index]);
                                } else {
                                  favorites.remove(shoes[index]);
                                }
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        shoes[index].name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16.0,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        '₹${shoes[index].price}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16.0,
                          color: Colors.green,
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: cart.contains(shoes[index])
                          ? null
                          : () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    backgroundColor: Colors.white,
                                    title: Text('Item Added to Cart'),
                                    content: Text(
                                        'The item ${shoes[index].name} has been added to your cart.'),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: Text('OK'),
                                      ),
                                    ],
                                  );
                                },
                              );
                              setState(() {
                                cart.add(shoes[index]);
                              });
                            },
                      child: Text('Add to Cart'),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        currentIndex: 0,
        onTap: (index) {
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FavoritesPage(),
              ),
            );
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CartPage(),
              ),
            );
          }
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favorites',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart_checkout_rounded),
            label: 'Cart',
          ),
        ],
      ),
    );
  }

  void _showFilterOptions(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Filter Options: Price'),
          backgroundColor: Colors.white,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildFilterOption('Ascending Price', 'asc'),
              _buildFilterOption('Descending Price', 'desc'),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterOption(String label, String value) {
    return InkWell(
      onTap: () {
        setState(() {
          selectedFilter = value;
        });
        Navigator.pop(context);
        _applyFilter(value);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: (selectedFilter == value) ? FontWeight.bold : null,
            color: (selectedFilter == value) ? Color(0xff1c2fac) : null,
          ),
        ),
      ),
    );
  }

  void _applyFilter(String value) {
    switch (value) {
      case 'asc':
        shoes.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'desc':
        shoes.sort((a, b) => b.price.compareTo(a.price));
        break;
      default:
        break;
    }
  }
}

class FavoritesPage extends StatefulWidget {
  @override
  _FavoritesPageState createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Favorites'),
      ),
      body: ListView.builder(
        itemCount: favorites.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: Image.network(
              favorites[index].imageUrl,
              height: 50,
              width: 50,
            ),
            title: Text(favorites[index].name),
            trailing: IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {
                // Remove item from favorites
                setState(() {
                  favorites.removeAt(index);
                });
              },
            ),
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        currentIndex: 1,
        onTap: (index) {
          if (index == 0) {
            Navigator.pop(context);
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CartPage(),
              ),
            );
          }
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favorites',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart_checkout_rounded),
            label: 'Cart',
          ),
        ],
      ),
    );
  }
}

class CartPage extends StatefulWidget {
  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Shopping Cart'),
        actions: [
          IconButton(
            icon: Icon(Icons.delete_forever),
            onPressed: () {
              // Clear cart
              setState(() {
                cart.clear();
              });
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: cart.length,
        itemBuilder: (context, index) {
          return Column(
            children: [
              ListTile(
                leading: Image.network(
                  cart[index].imageUrl,
                  height: 80,
                  width: 80,
                ),
                title: Text(
                  cart[index].name,
                  style: TextStyle(fontSize: 18),
                ),
                subtitle: Text(
                  '₹${cart[index].price}',
                  style: TextStyle(fontSize: 16, color: Colors.green),
                ),
                trailing: IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    // Remove item from cart
                    setState(() {
                      cart.removeAt(index);
                    });
                  },
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  // Proceed to checkout for this specific item
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ShoeDetailPage(
                        shoe: cart[index],
                      ),
                    ),
                  );
                },
                child: Text('Proceed to Checkout'),
              ),
              Divider(), // Add a divider between items for visual separation
            ],
          );
        },
      ),
    );
  }
}

class ShoeDetailPage extends StatefulWidget {
  final Shoe shoe;

  const ShoeDetailPage({Key? key, required this.shoe}) : super(key: key);

  @override
  _ShoeDetailPageState createState() => _ShoeDetailPageState();
}

class _ShoeDetailPageState extends State<ShoeDetailPage> {
  int quantity = 1;
  String selectedSize = 'UK7'; // Default selected size

  List<String> availableSizes = [
    'UK7',
    'UK8',
    'UK9',
    'UK10'
  ]; // List of available sizes

  @override
  Widget build(BuildContext context) {
    int totalPrice = widget.shoe.price * quantity;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.shoe.name),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              height: 300, // Adjust height as needed
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15.0),
                image: DecorationImage(
                  image: NetworkImage(widget.shoe.imageUrl),
                  fit: BoxFit.fill,
                ),
              ),
            ),
            SizedBox(height: 20),
            Text(
              '${widget.shoe.name}',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text(
              '₹${widget.shoe.price}',
              style: TextStyle(
                fontSize: 30,
                color: Colors.green,
              ),
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(Icons.remove),
                  onPressed: () {
                    if (quantity > 1) {
                      setState(() {
                        quantity--;
                      });
                    }
                  },
                ),
                Text('$quantity'),
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () {
                    setState(() {
                      quantity++;
                    });
                  },
                ),
              ],
            ),
            SizedBox(height: 20),
            Text(
              'Total Price: ₹$totalPrice',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            SizedBox(height: 20),
            // Size Selector
            SizedBox(
              height: 50,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: availableSizes.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          selectedSize = availableSizes[index];
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        primary: selectedSize == availableSizes[index]
                            ? Colors.blue
                            : Colors.grey,
                      ),
                      child: Text(
                        availableSizes[index],
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                double cgst = totalPrice * 0.025;
                double sgst = totalPrice * 0.025;
                double totalAmount = totalPrice + cgst + sgst;

                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      backgroundColor: Colors.white,
                      title: Text('Confirm Purchase'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Total Price: ₹$totalPrice'),
                          Text('CGST (2.5%): ₹${cgst.toStringAsFixed(2)}'),
                          Text('SGST (2.5%): ₹${sgst.toStringAsFixed(2)}'),
                          SizedBox(height: 10),
                          Text(
                              'Total Amount: ₹${totalAmount.toStringAsFixed(2)}'),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  backgroundColor: Colors.white,
                                  title: Text('Order Placed Successfully'),
                                  content: Text(
                                    'Your order will be delivered by ${DateTime.now().add(Duration(days: 1)).toString().substring(0, 10)}',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: Text('OK'),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          child: Text('Confirm'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text('Cancel'),
                        ),
                      ],
                    );
                  },
                );
              },
              child: Text('Buy Now'),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        currentIndex: 0,
        onTap: (index) {
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FavoritesPage(),
              ),
            );
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CartPage(),
              ),
            );
          }
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favorites',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart_checkout_rounded),
            label: 'Cart',
          ),
        ],
      ),
    );
  }
}

class Shoe {
  final String name;
  final int price;
  final String imageUrl;
  bool isFavorite;

  Shoe({
    required this.name,
    required this.price,
    required this.imageUrl,
    this.isFavorite = false,
  });
}

List<Shoe> shoes = [
  Shoe(
    name: 'Abbibas',
    price: 2000,
    imageUrl:
        'https://m.media-amazon.com/images/I/51IHg9i6ueL._AC_UL480_FMwebp_QL65_.jpg',
  ),
  Shoe(
    name: 'Nyki',
    price: 2500,
    imageUrl:
        'https://m.media-amazon.com/images/I/51U6OdzMF+L._AC_UL480_FMwebp_QL65_.jpg',
  ),
  Shoe(
    name: 'Pooma',
    price: 1800,
    imageUrl:
        'https://m.media-amazon.com/images/I/61utX8kBDlL._AC_UL480_FMwebp_QL65_.jpg',
  ),
  Shoe(
    name: 'Michel Ordan',
    price: 3000,
    imageUrl:
        'https://m.media-amazon.com/images/I/61luLIgsUKL._AC_UL480_QL65_.jpg',
  ),
  Shoe(
    name: 'Fampus',
    price: 2200,
    imageUrl:
        'https://m.media-amazon.com/images/I/71cflgAolqL._AC_UL480_FMwebp_QL65_.jpg',
  ),
  Shoe(
    name: 'Ankur',
    price: 1600,
    imageUrl:
        'https://m.media-amazon.com/images/I/61lHu4-ESDS._AC_UL480_FMwebp_QL65_.jpg',
  ),
  Shoe(
    name: 'Luvis',
    price: 2800,
    imageUrl:
        'https://m.media-amazon.com/images/I/51yb1ujmwBL._AC_UL480_QL65_.jpg',
  ),
  Shoe(
    name: 'Sparx',
    price: 1500,
    imageUrl:
        'https://m.media-amazon.com/images/I/41N8znMRUKL._AC_SR250,250_QL65_.jpg',
  ),
  Shoe(
    name: 'Skechers',
    price: 3200,
    imageUrl:
        'https://m.media-amazon.com/images/I/71dUVLkcWPL._AC_UL480_FMwebp_QL65_.jpg',
  ),
  Shoe(
    name: 'Bata',
    price: 1900,
    imageUrl:
        'https://m.media-amazon.com/images/I/51omEleCZnL._AC_UL480_FMwebp_QL65_.jpg',
  ),
  Shoe(
    name: 'Woodland',
    price: 3500,
    imageUrl:
        'https://m.media-amazon.com/images/I/61vuB6W7GLL._AC_UL480_FMwebp_QL65_.jpg',
  ),
  Shoe(
    name: 'Adidas',
    price: 2700,
    imageUrl:
        'https://m.media-amazon.com/images/I/71xnUrUdAUL._AC_UL480_FMwebp_QL65_.jpg',
  ),
  Shoe(
    name: 'Reebok',
    price: 2300,
    imageUrl:
        'https://m.media-amazon.com/images/I/81epuNcWP3L._AC_UL480_FMwebp_QL65_.jpg',
  ),
  Shoe(
    name: 'Lee Cooper',
    price: 2000,
    imageUrl:
        'https://m.media-amazon.com/images/I/71chIep9O6L._AC_UL480_FMwebp_QL65_.jpg',
  ),
  Shoe(
    name: 'Red Tape',
    price: 2600,
    imageUrl:
        'https://m.media-amazon.com/images/I/61VzAAvV6RL._AC_UL480_FMwebp_QL65_.jpg',
  ),
  Shoe(
    name: 'Clarks',
    price: 2800,
    imageUrl:
        'https://m.media-amazon.com/images/I/61ahHMqeaaL._AC_UL480_FMwebp_QL65_.jpg',
  ),
  Shoe(
    name: 'Puma',
    price: 2400,
    imageUrl:
        'https://m.media-amazon.com/images/I/71+dEU7Mx+L._AC_UL480_FMwebp_QL65_.jpg',
  ),
  Shoe(
    name: 'Nike',
    price: 2900,
    imageUrl:
        'https://m.media-amazon.com/images/I/71G-q545xgL._AC_UL480_FMwebp_QL65_.jpg',
  ),
  Shoe(
    name: 'Sparx',
    price: 2100,
    imageUrl:
        'https://m.media-amazon.com/images/I/51K-j2FYiOL._AC_UL480_FMwebp_QL65_.jpg',
  ),
  Shoe(
    name: 'Adidas',
    price: 3200,
    imageUrl:
        'https://m.media-amazon.com/images/I/71xp8lc6BjL._AC_UL480_FMwebp_QL65_.jpg',
  ),
  Shoe(
    name: 'Reebok',
    price: 2700,
    imageUrl:
        'https://m.media-amazon.com/images/I/61RFlIUeaIL._AC_UL480_FMwebp_QL65_.jpg',
  ),
  Shoe(
    name: 'Woodland',
    price: 3000,
    imageUrl:
        'https://m.media-amazon.com/images/I/61jbLbXriAL._AC_UL480_FMwebp_QL65_.jpg',
  ),
  Shoe(
    name: 'Lee Cooper',
    price: 2300,
    imageUrl:
        'https://m.media-amazon.com/images/I/51QVGip4gEL._AC_UL480_FMwebp_QL65_.jpg',
  ),
  Shoe(
    name: 'Red Tape',
    price: 2800,
    imageUrl:
        'https://m.media-amazon.com/images/I/710+PeurQiL._AC_UL480_FMwebp_QL65_.jpg',
  ),
  Shoe(
    name: 'Clarks',
    price: 2500,
    imageUrl:
        'https://m.media-amazon.com/images/I/7116DVkEANL._AC_UL480_FMwebp_QL65_.jpg',
  ),
  Shoe(
    name: 'Puma',
    price: 2200,
    imageUrl:
        'https://m.media-amazon.com/images/I/512cMTlNQ7L._AC_UL480_QL65_.jpg',
  ),
  Shoe(
    name: 'Nike',
    price: 3400,
    imageUrl:
        'https://m.media-amazon.com/images/I/610fN3RyKFL._AC_UL480_QL65_.jpg',
  ),
];

List<Shoe> favorites = [];

List<Shoe> cart = [];

class ShoeSearchDelegate extends SearchDelegate<String> {
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final results = shoes
        .where((shoe) => shoe.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(results[index].name),
          onTap: () {
            close(context, results[index].name);
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final results = shoes
        .where((shoe) => shoe.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(results[index].name),
          onTap: () {
            query = results[index].name;
            showResults(context);
          },
        );
      },
    );
  }
}

class AnimatedScaleOnHover extends StatefulWidget {
  final double scale;
  final Widget child;

  AnimatedScaleOnHover({required this.child, required this.scale});

  @override
  _AnimatedScaleOnHoverState createState() => _AnimatedScaleOnHoverState();
}

class _AnimatedScaleOnHoverState extends State<AnimatedScaleOnHover> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _mouseEnter(true),
      onExit: (_) => _mouseEnter(false),
      child: TweenAnimationBuilder(
        tween: Tween<double>(begin: 1, end: widget.scale),
        duration: Duration(milliseconds: 200),
        builder: (BuildContext context, double value, Widget? child) {
          return Transform.scale(
            scale: _hovering ? value : 1,
            child: child,
          );
        },
        child: widget.child,
      ),
    );
  }

  void _mouseEnter(bool hover) {
    setState(() {
      _hovering = hover;
    });
  }
}
