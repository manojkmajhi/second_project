import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:random_string/random_string.dart';
import 'package:second_project/widget/support_widget.dart';

class AddProduct extends StatefulWidget {
  const AddProduct({super.key});

  @override
  State<AddProduct> createState() => _AddProductState();
}

class _AddProductState extends State<AddProduct> {
  final ImagePicker _picker = ImagePicker();
  File? selectedImage;

  Future getImage() async {
    final image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        selectedImage = File(image.path);
      });
    }
  }

  uploadItem() async {
    if (selectedImage != null && _nameController.text != "") {
      String addId = randomAlphaNumeric(10);
      Reference firebaseStorageRef = FirebaseStorage.instance
          .ref()
          .child("productImages")
          .child("$addId.jpg");

      UploadTask uploadTask = firebaseStorageRef.putFile(selectedImage!);
      TaskSnapshot taskSnapshot = await uploadTask;

      String downloadUrl = await taskSnapshot.ref.getDownloadURL();

      print("Uploaded Image URL: $downloadUrl");
      // You can now store this URL in Firestore or your backend
    }
  }

  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  String? value;

  final List<String> categoryItem = [
    "Daily Use",
    "Agricultural",
    "Electrical",
    "Others",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 250, 247, 247),
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 235, 235, 235),
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(Icons.arrow_back_ios, color: Colors.black),
        ),
        title: Center(
          child: Text('Add Product', style: AppWidget.semiboldTextFieldStyle()),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.only(top: 20.0, left: 20.0, right: 20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    'Upload the product Image',
                    style: AppWidget.lightTextFieldStyle(),
                  ),
                ),
                SizedBox(height: 20.0),
                Center(
                  child: GestureDetector(
                    onTap: getImage,
                    child: Container(
                      height: 150,
                      width: 150,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(20.0)),
                        border: Border.all(color: Colors.black),
                        image:
                            selectedImage != null
                                ? DecorationImage(
                                  image: FileImage(selectedImage!),
                                  fit: BoxFit.cover,
                                )
                                : null,
                      ),
                      child:
                          selectedImage == null
                              ? Icon(
                                Icons.camera_alt,
                                size: 50.0,
                                color: Colors.grey,
                              )
                              : null,
                    ),
                  ),
                ),
                SizedBox(height: 20.0),
                // Text('Product Name', style: AppWidget.lightTextFieldStyle()),
                // SizedBox(height: 5.0),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      labelText: 'Enter Product Name',
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Product name cannot be empty';
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(height: 10.0),
                // Text('Product Price', style: AppWidget.lightTextFieldStyle()),
                // SizedBox(height: 5.0),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: TextFormField(
                    controller: _priceController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      labelText: 'Enter Product Price',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a price';
                      }
                      final price = double.tryParse(value);
                      if (price == null) {
                        return 'Enter a valid number';
                      }
                      if (price < 0) {
                        return 'Price cannot be negative';
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(height: 20.0),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.0),
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10.0),
                    border: Border.all(color: Colors.black),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      items:
                          categoryItem
                              .map(
                                (item) => DropdownMenuItem(
                                  value: item,
                                  child: Text(
                                    item,
                                    style: AppWidget.semiboldTextFieldStyle(),
                                  ),
                                ),
                              )
                              .toList(),
                      onChanged:
                          ((value) => setState(() {
                            this.value = value;
                          })),
                      dropdownColor: Colors.white,
                      hint: Text("Select Category"),
                      iconSize: 36,
                      icon: Icon(Icons.arrow_drop_down, color: Colors.black),
                      value: value,
                    ),
                  ),
                ),
                SizedBox(height: 20.0),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Enter product description',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10.0),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  width: MediaQuery.of(context).size.width,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      backgroundColor: Color.fromARGB(255, 0, 0, 0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    child: Text(
                      'Add Product',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        uploadItem(); // Upload image to Firebase
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: Colors.green,
                            content: Text('Product added successfully'),
                          ),
                        );
                      }
                    },
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
