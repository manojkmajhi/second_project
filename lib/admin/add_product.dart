import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:second_project/data/local/db_helper.dart';
import 'package:second_project/widget/support_widget.dart';

class AddProduct extends StatefulWidget {
  const AddProduct({super.key});

  @override
  State<AddProduct> createState() => _AddProductState();
}

class _AddProductState extends State<AddProduct> {
  final ImagePicker _picker = ImagePicker();
  File? selectedImage;

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _detailsController = TextEditingController();

  String? value;
  final List<String> categoryItem = [
    "Daily Use",
    "Agricultural",
    "Electrical",
    "Construction",
  ];

  Future<void> getImage() async {
    final image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        selectedImage = File(image.path);
      });
    }
  }

  Future<void> saveProductToDB() async {
    if (!_formKey.currentState!.validate()) return;

    final db = await DBHelper.getInstance.getDB();

    await db.insert("product", {
      "product_name": _nameController.text,
      "product_price": double.parse(_priceController.text),
      "details": _detailsController.text,
      "category": value ?? 'Others',
      "image_path": selectedImage?.path ?? '',
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Product saved successfully!")),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 250, 247, 247),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 235, 235, 235),
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back_ios, color: Colors.black),
        ),
        title: Center(
          child: Text('Add Product', style: AppWidget.semiboldTextFieldStyle()),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Center(
                  child: Text(
                    'Upload the product Image',
                    style: AppWidget.lightTextFieldStyle(),
                  ),
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: getImage,
                  child: Container(
                    height: 150,
                    width: 150,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
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
                            ? const Icon(
                              Icons.camera_alt,
                              size: 50,
                              color: Colors.grey,
                            )
                            : null,
                  ),
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  _nameController,
                  'Enter Product Name',
                  'Product name cannot be empty',
                ),
                const SizedBox(height: 10),
                _buildTextField(
                  _priceController,
                  'Enter Product Price',
                  'Enter valid price',
                  isNumber: true,
                ),
                const SizedBox(height: 10),
                _buildDropdown(),
                const SizedBox(height: 10),
                _buildDescriptionField(),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: saveProductToDB,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 20,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Add Product',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    String errorText, {
    bool isNumber = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) return errorText;
          if (isNumber && double.tryParse(value) == null)
            return 'Enter a valid number';
          return null;
        },
      ),
    );
  }

  Widget _buildDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: const Text("Select Category"),
          icon: const Icon(Icons.arrow_drop_down),
          iconSize: 36,
          isExpanded: true,
          items:
              categoryItem.map((item) {
                return DropdownMenuItem(value: item, child: Text(item));
              }).toList(),
          onChanged: (val) => setState(() => value = val),
        ),
      ),
    );
  }

  Widget _buildDescriptionField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextFormField(
        controller: _detailsController,
        maxLines: 3,
        decoration: InputDecoration(
          hintText: 'Enter product description',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.black),
          ),
        ),
      ),
    );
  }
}
