import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../global/global_instances.dart';

class SelectAddressScreen extends StatefulWidget {
  @override
  _SelectAddressScreenState createState() => _SelectAddressScreenState();
}

class _SelectAddressScreenState extends State<SelectAddressScreen> {
  Map<String, String>? selectedAddress;
  String? userName;
  String? userPhone;
  String? userPrimaryAddress;
  final TextEditingController locationController = TextEditingController();
  List<Map<String, String>> addresses = [];
  bool isLoadingLocation = false;
  bool isLoadingSignUp = false;

  @override
  void initState() {
    super.initState();
    fetchUserDetails();
  }

  Future<void> fetchUserDetails() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        setState(() {
          userName = userDoc['name'];
          userPhone = userDoc['phone'];
          userPrimaryAddress = userDoc['address'];
          addresses = [
            {
              'name': userDoc['name'],
              'phone': userDoc['phone'],
              'address': userDoc['address']
            }
          ]; // Initialize with primary address
        });

        // Fetch additional addresses from subcollection
        QuerySnapshot addressDocs = await FirebaseFirestore.instance.collection('users').doc(user.uid).collection('addresses').get();
        List<Map<String, String>> additionalAddresses = addressDocs.docs.map((doc) => {
          'name': doc['name'] as String,
          'phone': doc['phone'] as String,
          'address': doc['address'] as String,
        }).toList();

        setState(() {
          addresses.addAll(additionalAddresses);
        });
      }
    }
  }

  Future<void> addNewAddress(String name, String phone, String address) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).collection('addresses').add({
        'name': name,
        'phone': phone,
        'address': address,
      });
      setState(() {
        addresses.add({'name': name, 'phone': phone, 'address': address});
      });
    }
  }

  void _showAddAddressDialog() {
    final _formKey = GlobalKey<FormState>();
    String? name;
    String? phone;
    String? address;
    locationController.clear(); // Clear the TextEditingController

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add New Address'),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextFormField(
                  decoration: InputDecoration(labelText: 'Name'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    name = value;
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Phone'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your phone number';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    phone = value;
                  },
                ),
                TextFormField(
                  controller: locationController,
                  decoration: InputDecoration(labelText: 'Address'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your address';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    address = value;
                  },
                ),
                ElevatedButton(
                  onPressed: () async {
                    setState(() {
                      isLoadingLocation = true;
                    });
                    String address = await commonViewModel.getCurrentLocation();
                    setState(() {
                      locationController.text = address;
                      isLoadingLocation = false;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.greenAccent,
                    padding: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(40),
                    ),
                  ),
                  child: isLoadingLocation
                      ? CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color.fromRGBO(255, 63, 111, 1),
                    ),
                  )
                      : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Icon(
                        Icons.location_on_outlined,
                        color: Color.fromRGBO(255, 63, 111, 1),
                      ),
                      SizedBox(width: 10),
                      Text(
                        'Get My Location',
                        style: TextStyle(
                          color: Color.fromRGBO(255, 63, 111, 1),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Add'),
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  addNewAddress(name!, phone!, address!);
                  Navigator.of(context).pop();
                  commonViewModel.showSnackBar("Address Added Successfully", context);
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Address'),
        backgroundColor: Colors.redAccent,
      ),
      body: addresses.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: addresses.length,
        itemBuilder: (context, index) {
          bool isPrimary = index == 0;
          var address = addresses[index];
          return RadioListTile(
            value: address,
            groupValue: selectedAddress,
            onChanged: (Map<String, String>? value) {
              setState(() {
                selectedAddress = value;
              });
              Navigator.pop(context, value);
            },
            title: isPrimary
                ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Primary Address', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                Text('Name: ${address['name']}', style: TextStyle(color: Colors.black)),
                Text('Phone: ${address['phone']}', style: TextStyle(color: Colors.black)),
                Text('Address: ${address['address']}', style: TextStyle(color: Colors.black)),
              ],
            )
                : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Name: ${address['name']}', style: TextStyle(color: Colors.black)),
                Text('Phone: ${address['phone']}', style: TextStyle(color: Colors.black)),
                Text('Address: ${address['address']}', style: TextStyle(color: Colors.black)),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddAddressDialog,
        child: Icon(Icons.add_location),
        backgroundColor: Colors.redAccent,
      ),
    );
  }
}
