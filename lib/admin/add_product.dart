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
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _detailsController = TextEditingController();

  // Make sure this is directly linked to the dropdown's value
  String? selectedCategory;
  bool isLoading = false;

  final List<String> categoryItem = [
    "All",
    "Daily Use",
    "Electrical",
    "Agricultural",
  ];

  Future<void> getImage() async {
    showModalBottomSheet(
      context: context,
      builder:
          (context) => Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take a photo'),
                onTap: () async {
                  Navigator.pop(context);
                  final image = await _picker.pickImage(
                    source: ImageSource.camera,
                  );
                  if (image != null) {
                    setState(() => selectedImage = File(image.path));
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from gallery'),
                onTap: () async {
                  Navigator.pop(context);
                  final image = await _picker.pickImage(
                    source: ImageSource.gallery,
                  );
                  if (image != null) {
                    setState(() => selectedImage = File(image.path));
                  }
                },
              ),
            ],
          ),
    );
  }

  Future<void> saveProductToDB() async {
    if (!_formKey.currentState!.validate()) return;

    if (selectedImage == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please select an image.")));
      return;
    }

    // This is the correct check, ensure selectedCategory is updated
    if (selectedCategory == null ||
        selectedCategory!.isEmpty ||
        selectedCategory == "All") {
      // Added || selectedCategory == "All" for robustness
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a valid category.")),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final db = await DBHelper.instance.getDB();
      final trimmedName = _nameController.text.trim();
      final imagePath = selectedImage!.path;

      // Check for duplicate name
      final existingByName = await db.query(
        DBHelper.productTableName, // Use constant for table name
        where: 'product_name = ?',
        whereArgs: [trimmedName],
      );
      if (existingByName.isNotEmpty) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("A product with this name already exists."),
          ),
        );
        return;
      }

      // Check for duplicate image
      final existingByImage = await db.query(
        DBHelper.productTableName, // Use constant for table name
        where: 'image_path = ?',
        whereArgs: [imagePath],
      );
      if (existingByImage.isNotEmpty) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("A product with this image already exists."),
          ),
        );
        return;
      }

      await db.insert(DBHelper.productTableName, {
        // Use constant for table name
        "product_name": trimmedName,
        "product_price": double.parse(_priceController.text),
        "product_quantity": int.parse(_quantityController.text),
        "details": _detailsController.text.trim(),
        "category": selectedCategory!, // Use selectedCategory here
        "image_path": imagePath,
      });

      setState(() => isLoading = false);

      final result = await showDialog(
        context: context,
        builder:
            (ctx) => AlertDialog(
              title: const Text("Product Saved"),
              content: const Text("Do you want to add another product?"),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text("No"),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: const Text("Yes"),
                ),
              ],
            ),
      );

      if (result == true) {
        _formKey.currentState!.reset();
        _nameController.clear();
        _priceController.clear();
        _quantityController.clear();
        _detailsController.clear();
        setState(() {
          selectedImage = null;
          selectedCategory = null; // Reset category for new product
        });
      } else {
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() => isLoading = false);
      debugPrint("Error saving product: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error saving product: $e")));
    }
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
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
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
                        const SizedBox(height: 10),
                        GestureDetector(
                          onTap: getImage,
                          child: Container(
                            height: 120,
                            width: 120,
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
                        const SizedBox(height: 10),
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
                        _buildTextField(
                          _quantityController,
                          'Enter Product Quantity',
                          'Enter valid quantity',
                          isNumber: true,
                        ),
                        const SizedBox(height: 10),
                        _buildCategoryDropdown(),
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
        keyboardType:
            isNumber
                ? const TextInputType.numberWithOptions(decimal: true)
                : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) return errorText;
          if (isNumber) {
            final parsed = double.tryParse(value);
            if (parsed == null || parsed < 0)
              return 'Enter a valid positive number';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade400, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedCategory, // Use selectedCategory here
          isExpanded: true,
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: Colors.black,
          ),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
          dropdownColor: Colors.white,
          borderRadius: BorderRadius.circular(12),
          hint: const Text(
            "Select Category",
            style: TextStyle(fontSize: 16, color: Colors.black54),
          ),
          items:
              categoryItem.map((item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Text(item),
                  ),
                );
              }).toList(),
          onChanged: (val) {
            setState(() {
              selectedCategory = val; // Update selectedCategory
            });
          },
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
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }
}
