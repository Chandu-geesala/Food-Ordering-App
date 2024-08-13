import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:user_app/global/global_vars.dart';
import 'package:user_app/view/mainScreens/orderDisplay.dart';
import 'menuScreen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String fulladdress = sharedPreferences!.getString("address") ?? "Fetching Address";

  final List<String> imgList = [
    'slider/R.jpeg',
    'slider/S.jpeg',
    'slider/T.jpeg',
    'slider/U.jpeg',
  ];

  final List<String> cardImages = [
    'slider/0.jpg',
    'slider/25.jpg',
    'slider/24.jpg',
  ];

  final List<String> cardTypes = [
    'Restaurant',
    'Fast Food',
    'Cafe',
  ];

  final List<String> cardRatings = [
    '4.5',
    '4.0',
    '4.7',
  ];

  final List<Map<String, String>> menuItems = [
    {'name': 'Pizza', 'image': 'slider/1.jpg'},
    {'name': 'Burger', 'image': 'slider/15.jpg'},
    {'name': 'Fries', 'image': 'slider/22.jpg'},
    {'name': 'Chicken', 'image': 'slider/20.jpg'},
    {'name': 'Milkshake', 'image': 'slider/24.jpg'},
    {'name': 'Rakhi Specials', 'image': 'slider/26.jpg'},
    // Add more items as needed
  ];

  String searchQuery = '';

  String getFullAddress() {
    final delimiter = ',,';
    final delimiterIndex = fulladdress.indexOf(delimiter);
    final subaddress = delimiterIndex != -1 ? fulladdress.substring(0, delimiterIndex).trim() : fulladdress;
    return subaddress.replaceAll(',', '');
  }

  String getSubaddress() {
    final delimiter = ',,';
    final delimiterIndex = fulladdress.indexOf(delimiter);
    if (delimiterIndex == -1) return fulladdress;

    final subaddressPart = fulladdress.substring(delimiterIndex + delimiter.length).trim();
    final lastCommaIndex = subaddressPart.lastIndexOf(',');
    final secondLastCommaIndex = subaddressPart.substring(0, lastCommaIndex).lastIndexOf(',');

    if (secondLastCommaIndex == -1) {
      return subaddressPart.replaceAll(',', '');
    } else {
      return subaddressPart.substring(0, secondLastCommaIndex).replaceAll(',', '').trim();
    }
  }

  Future<List<Map<String, dynamic>>> fetchSellers() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('sellers').get();
    return snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
  }

  Future<List<Map<String, dynamic>>> fetchItems() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('items').get();
    return snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
  }

  List<Map<String, dynamic>> filterSellers(List<Map<String, dynamic>> sellers) {
    if (searchQuery.isEmpty) {
      return sellers;
    }
    return sellers.where((seller) =>
    seller['name'].toString().toLowerCase().contains(searchQuery.toLowerCase()) ||
        seller['email'].toString().toLowerCase().contains(searchQuery.toLowerCase())).toList();
  }

  List<Map<String, dynamic>> filterItems(List<Map<String, dynamic>> items) {
    if (searchQuery.isEmpty) {
      return [];
    }
    return items.where((item) =>
        item['menuTitle'].toString().toLowerCase().contains(searchQuery.toLowerCase())).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildTopBar(context),
            _buildSearchBar(context),
            _buildCarousel(),
            _buildHorizontalButtons(),
            _buildHorizontalMenu(),
            _buildSearchResults(),  // Update this line
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 40.0, left: 16.0, right: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  getFullAddress(),
                  style: GoogleFonts.lato(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4.0),
                Text(
                  getSubaddress(),
                  style: GoogleFonts.lato(
                    fontSize: 14.0,
                    color: Colors.grey,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => OrderDisplayPage(),
                ),
              );
            },
            child: CircleAvatar(
              backgroundColor: Colors.grey[200],
              child: Icon(Icons.shopping_cart, color: Colors.grey[800]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 5,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: TextField(
          onChanged: (value) {
            setState(() {
              searchQuery = value;
            });
          },
          decoration: InputDecoration(
            hintText: "Search for 'Cake'",
            hintStyle: TextStyle(color: Colors.grey),
            prefixIcon: Icon(Icons.search, color: Colors.redAccent),
            suffixIcon: Icon(Icons.mic, color: Colors.redAccent),
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }

  Widget _buildCarousel() {
    return CarouselSlider(
      options: CarouselOptions(
        autoPlay: false,
        aspectRatio: 2.0,
        enlargeCenterPage: false,
      ),
      items: imgList
          .map((item) => Container(
        margin: EdgeInsets.symmetric(horizontal: 5.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15.0),
          child: Image.asset(
            item,
            fit: BoxFit.cover,
            width: 10000.0,
            height: 1000.0,
          ),
        ),
      ))
          .toList(),
    );
  }

  Widget _buildHorizontalButtons() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildButton('Filter', Icons.filter_list_outlined),
            _buildButton('Sort by', Icons.arrow_drop_down),
            _buildButton('Offers', Icons.local_offer),
            _buildButton('Categories', Icons.category),
            _buildButton('Popular', Icons.star),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(String label, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: Colors.grey.shade300), // Light border color
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0),
          ),
          backgroundColor: Colors.white,
        ),
        onPressed: () {
          // Handle button press
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label, style: TextStyle(color: Colors.black)),
            SizedBox(width: 8.0),
            Icon(icon, color: Colors.black),
          ],
        ),
      ),
    );
  }

  Widget _buildHorizontalMenu() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "What's on your mind?",
            style: GoogleFonts.lato(fontSize: 18.0, fontWeight: FontWeight.bold, color: Colors.black),
          ),
          SizedBox(height: 8.0),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: menuItems.map((item) {
                return Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: Column(
                    children: [
                      Container(
                        width: 60.0,
                        height: 60.0,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30.0),
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.3),
                              spreadRadius: 2,
                              blurRadius: 5,
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(30.0),
                          child: Image.asset(item['image']!, fit: BoxFit.cover),
                        ),
                      ),
                      SizedBox(height: 8.0),
                      Text(
                        item['name']!,
                        style: GoogleFonts.lato(fontSize: 14.0, color: Colors.black),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    return FutureBuilder<Map<String, dynamic>>(
      future: _fetchCombinedData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error fetching data'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No results found'));
        } else {
          final sellers = snapshot.data!['sellers'] as List<Map<String, dynamic>>;
          final items = snapshot.data!['items'] as List<Map<String, dynamic>>;
          return Column(
            children: [
              ...sellers.map((seller) {
                return _buildSellerCard(
                  seller['name'] ?? 'Unknown',
                  seller['email'] ?? 'No email',
                  seller['uid'] ?? '',
                  cardImages[sellers.indexOf(seller) % cardImages.length],
                  cardTypes[sellers.indexOf(seller) % cardTypes.length],
                  cardRatings[sellers.indexOf(seller) % cardRatings.length],
                );
              }).toList(),
              ...items.map((item) {
                return _buildItemCard(
                  item['menuTitle'] ?? 'Unknown',
                  item['menuImage'] ?? '',
                  item['menuId'] ?? '',
                  item['sellerUid'] ?? '',
                );
              }).toList(),
            ],
          );
        }
      },
    );
  }

  Future<Map<String, dynamic>> _fetchCombinedData() async {
    List<Map<String, dynamic>> sellers = await fetchSellers();
    List<Map<String, dynamic>> items = await fetchItems();

    // Filter the results based on the search query
    sellers = filterSellers(sellers);
    items = filterItems(items);

    return {
      'sellers': sellers,
      'items': items,
    };
  }

  Widget _buildSellerCard(String name, String email, String uid, String imageUrl, String type, String rating) {
    return Padding(
      padding: const EdgeInsets.all(14.0),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MenuDisplayScreen(sellerUid: uid),
            ),
          );
        },
        child: Card(
          color: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          elevation: 5,
          child: Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 150,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(15),
                      topRight: Radius.circular(15),
                    ),
                    image: DecorationImage(
                      image: AssetImage(imageUrl),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        name,
                        style: GoogleFonts.lato(fontSize: 20.0, fontWeight: FontWeight.bold, color: Colors.black),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                        child: Text(
                          'Type: $type',
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        email,
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                      Row(
                        children: [
                          Icon(Icons.star, color: Colors.amber, size: 20.0),
                          Text(
                            rating,
                            style: TextStyle(color: Colors.black),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildItemCard(String title, String imageUrl, String menuId, String sellerUid) {
    return Padding(
      padding: const EdgeInsets.all(14.0),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MenuDisplayScreen(sellerUid: sellerUid),
            ),
          );
        },
        child: Card(
          color: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          elevation: 5,
          child: Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 150,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(15),
                      topRight: Radius.circular(15),
                    ),
                    image: DecorationImage(
                      image: NetworkImage(imageUrl),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    title,
                    style: GoogleFonts.lato(fontSize: 20.0, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
