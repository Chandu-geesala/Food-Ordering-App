import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart' as storageRef;

class EditMenuItemScreen extends StatefulWidget {
  final String menuItemId;
  final Map<String, dynamic> menuItem;

  EditMenuItemScreen({required this.menuItemId, required this.menuItem});

  @override
  _EditMenuItemScreenState createState() => _EditMenuItemScreenState();
}

class _EditMenuItemScreenState extends State<EditMenuItemScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  late TextEditingController _categoryController;
  XFile? _imageFile;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.menuItem['menuTitle']);
    _descriptionController = TextEditingController(text: widget.menuItem['menuDescription']);
    _priceController = TextEditingController(text: widget.menuItem['menuPrice']);
    _categoryController = TextEditingController(text: widget.menuItem['menuCategory']);
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _imageFile = pickedFile;
    });
  }

  Future<String?> _uploadImage(File imageFile) async {
    try {
      String uniqueId = widget.menuItemId;
      storageRef.Reference reference = storageRef.FirebaseStorage.instance.ref().child("menus");
      storageRef.UploadTask uploadTask = reference.child(uniqueId + ".jpg").putFile(imageFile);
      storageRef.TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() {});
      String downloadURL = await taskSnapshot.ref.getDownloadURL();
      return downloadURL;
    } catch (e) {
      return null;
    }
  }

  void _deleteMenuItem() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await FirebaseFirestore.instance
          .collection("sellers")
          .doc(widget.menuItem['sellerUid'])
          .collection("menus")
          .doc(widget.menuItemId)
          .delete();

      Navigator.pop(context, true); // Return true to indicate delete success
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // Handle the error appropriately
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete the item: $e')),
      );
    }
  }


  void _updateMenuItem() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      String? imageUrl;
      if (_imageFile != null) {
        imageUrl = await _uploadImage(File(_imageFile!.path));
      }

      FirebaseFirestore.instance
          .collection("sellers")
          .doc(widget.menuItem['sellerUid'])
          .collection("menus")
          .doc(widget.menuItemId)
          .update({
        "menuTitle": _nameController.text,
        "menuDescription": _descriptionController.text,
        "menuPrice": _priceController.text,
        "menuCategory": _categoryController.text,
        if (imageUrl != null) "menuImage": imageUrl,
      }).then((_) {
        setState(() {
          _isLoading = false;
        });
        Navigator.pop(context, true);  // Return true to indicate update success
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Menu Item'),
        backgroundColor: Colors.redAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: _isLoading ? null : _pickImage,
                  child: Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(10.0),
                      border: Border.all(
                        color: Colors.black,
                        width: 1,
                      ),
                    ),
                    child: _imageFile == null && widget.menuItem['menuImage'] != null
                        ? ClipRRect(
                      borderRadius: BorderRadius.circular(10.0),
                      child: Image.network(
                        widget.menuItem['menuImage'],
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    )
                        : _imageFile != null
                        ? Image.file(
                      File(_imageFile!.path),
                      fit: BoxFit.cover,
                    )
                        : Center(
                      child: Text(
                        'Tap to select image',
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 16.0,
                        ),
                      ),
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
                TextFormField(
                  controller: _categoryController,
                  decoration: InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.redAccent),
                    ),
                  ),
                  style: TextStyle(color: Colors.black),
                  enabled: !_isLoading,
                ),
                SizedBox(height: 16.0),

                Center(
                  child: _isLoading
                      ? CircularProgressIndicator()
                      : Column(
                    children: [
                      ElevatedButton(
                        onPressed: _updateMenuItem,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.greenAccent,
                          padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                          textStyle: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        child: Text('Update'),
                      ),
                      SizedBox(height: 16.0),
                      ElevatedButton(
                        onPressed: _isLoading ? null : _deleteMenuItem,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                          textStyle: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        child: Text('Delete'),
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
}
