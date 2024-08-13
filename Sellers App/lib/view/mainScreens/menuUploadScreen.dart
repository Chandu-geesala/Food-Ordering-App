import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart' as storageRef;
import 'package:seller_app/global/global_vars.dart';
import 'package:seller_app/view/mainScreens/MyMenu.dart';
import 'package:seller_app/viewModel/common_view_model.dart';

import '../../global/global_instances.dart';
import 'HomeScreen.dart';
import 'NewOrders.dart';

class MenuUploadScreen extends StatefulWidget {
  @override
  _MenuUploadScreenState createState() => _MenuUploadScreenState();
}

class _MenuUploadScreenState extends State<MenuUploadScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _categoryController = TextEditingController();
  XFile? _imageFile;
  final ImagePicker _picker = ImagePicker();
  String uniqueId = DateTime.now().millisecondsSinceEpoch.toString();
  bool _isLoading = false;
  String _selectedCategory = '';

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _imageFile = pickedFile;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Upload Menu Item'),
        backgroundColor: Colors.redAccent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.push(
                context, MaterialPageRoute(builder: (c) => HomeScreen()));
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Add a New Menu Item',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.redAccent,
                  ),
                ),
                SizedBox(height: 16.0),
                GestureDetector(
                  onTap: _isLoading ? null : _pickImage,
                  child: Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(10.0),
                      border: Border.all(
                        color: Colors.grey,
                        width: 1,
                      ),
                    ),
                    child: _imageFile == null
                        ? Center(
                      child: Text(
                        'Tap to select image',
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 16.0,
                        ),
                      ),
                    )
                        : Image.file(
                      File(_imageFile!.path),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SizedBox(height: 16.0),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Name',
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.redAccent),
                    ),
                  ),
                  style: TextStyle(color: Colors.black),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the name';
                    }
                    return null;
                  },
                  enabled: !_isLoading,
                ),
                SizedBox(height: 16.0),
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.redAccent),
                    ),
                  ),
                  style: TextStyle(color: Colors.black),
                  maxLines: 3,
                  enabled: !_isLoading,
                ),
                SizedBox(height: 16.0),
                TextFormField(
                  controller: _priceController,
                  decoration: InputDecoration(
                    labelText: 'Price',
                    prefixText: '₹',
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.redAccent),
                    ),
                  ),
                  style: TextStyle(color: Colors.black),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the price';
                    }
                    return null;
                  },
                  enabled: !_isLoading,
                ),
                SizedBox(height: 16.0),
                IgnorePointer(
                  ignoring: _isLoading,
                  child: DropdownButtonFormField<String>(
                    items: [
                      DropdownMenuItem(child: Text("Fried Rice"), value: "Fried Rice"),
                      DropdownMenuItem(child: Text("Pasta"), value: "Pasta"),
                      DropdownMenuItem(child: Text("Pizza"), value: "Pizza"),
                      DropdownMenuItem(child: Text("Burgers"), value: "Burgers"),
                      DropdownMenuItem(child: Text("Sandwiches"), value: "Sandwiches"),
                      DropdownMenuItem(child: Text("Salads"), value: "Salads"),
                      DropdownMenuItem(child: Text("Desserts"), value: "Desserts"),
                      DropdownMenuItem(child: Text("Beverages"), value: "Beverages"),
                      DropdownMenuItem(child: Text("Other"), value: "Other"),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedCategory = value ?? '';
                        _categoryController.text = _selectedCategory != "Other" ? _selectedCategory : '';
                      });
                    },
                    decoration: InputDecoration(
                      labelText: "Select Food Category",
                      border: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.redAccent),
                      ),
                    ),
                    style: TextStyle(color: Colors.black),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select or enter a category';
                      }
                      return null;
                    },
                  ),
                ),
                if (_selectedCategory == "Other") ...[
                  SizedBox(height: 16.0),
                  TextFormField(
                    controller: _categoryController,
                    decoration: InputDecoration(
                      labelText: 'Custom Category',
                      border: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.redAccent),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a custom category';
                      }
                      return null;
                    },
                    enabled: !_isLoading,
                  ),
                ],
                SizedBox(height: 16.0),
                Center(
                  child: _isLoading
                      ? CircularProgressIndicator()
                      : ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        if (_imageFile != null) {
                          setState(() {
                            _isLoading = true;
                          });
                          String downloadUrl = await uploadImage(File(_imageFile!.path));
                          saveInfo(downloadUrl);
                          setState(() {
                            _isLoading = false;
                          });

                          // Show success message and navigate to MyMenu
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Menu Created Successfully'),
                            ),
                          );

                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MyMenu(),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Please select an image')),
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                      textStyle: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    child: Text('Submit'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<String> uploadImage(File myImageFile) async {
    storageRef.Reference reference = storageRef.FirebaseStorage.instance.ref().child("menus");
    storageRef.UploadTask uploadTask = reference.child(uniqueId + ".jpg").putFile(myImageFile);
    storageRef.TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() {});
    String downloadURL = await taskSnapshot.ref.getDownloadURL();
    return downloadURL;
  }




  void saveInfo(String downloadUrl) {
    String sellerUid = sharedPreferences!.getString("uid")!;
    String menuTitle = _nameController.text.toString();
    String menuDescription = _descriptionController.text.toString();
    String menuPrice = _priceController.text.toString();
    String menuCategory = _categoryController.text.toString();

    // Save to the seller-specific collection
    final sellerRef = FirebaseFirestore.instance
        .collection("sellers")
        .doc(sellerUid)
        .collection("menus");

    sellerRef.doc(uniqueId).set({
      "menuId": uniqueId,
      "sellerUid": sellerUid,
      "menuTitle": menuTitle,
      "menuDescription": menuDescription,
      "menuPrice": menuPrice,
      "menuCategory": menuCategory,
      "menuImage": downloadUrl,
    });

    // Save to the common "items" collection
    final itemsRef = FirebaseFirestore.instance.collection("items");

    itemsRef.doc(uniqueId).set({
      "menuId": uniqueId,
      "sellerUid": sellerUid,
      "menuTitle": menuTitle,
      "menuImage": downloadUrl,
    });

    clearMenusUploadForm();

    setState(() {
      uniqueId = DateTime.now().millisecondsSinceEpoch.toString();
    });
  }





  void clearMenusUploadForm() {
    setState(() {
      _nameController.clear();
      _descriptionController.clear();
      _priceController.clear();
      _categoryController.clear();
      _imageFile = null;
      _selectedCategory = '';
    });
  }
}
