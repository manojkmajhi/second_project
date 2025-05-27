import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:second_project/data/local/db_helper.dart';
import 'package:second_project/widget/support_widget.dart';

class UpdateProduct extends StatefulWidget {
  final Map<String, dynamic> product;

  const UpdateProduct({super.key, required this.product});

  @override
  State<UpdateProduct> createState() => _UpdateProductState();
}

class _UpdateProductState extends State<UpdateProduct> {
  final ImagePicker _picker = ImagePicker();
  File? selectedImage;
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _quantityController;
  late TextEditingController _detailsController;

  String? selectedCategory;
  bool isLoading = false;

  final List<String> categoryItem = [
    "All",
    "Daily Use",
    "Electrical",
    "Agricultural",
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.product['product_name'],
    );
    _priceController = TextEditingController(
      text: widget.product['product_price'].toString(),
    );
    _quantityController = TextEditingController(
      text: widget.product['product_quantity'].toString(),
    );
    _detailsController = TextEditingController(text: widget.product['details']);
    selectedCategory = widget.product['category'];
    selectedImage = File(widget.product['image_path']);
  }

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
                  if (image != null)
                    setState(() => selectedImage = File(image.path));
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
                  if (image != null)
                    setState(() => selectedImage = File(image.path));
                },
              ),
            ],
          ),
    );
  }

  Future<void> updateProductToDB() async {
    if (!_formKey.currentState!.validate()) return;

    if (selectedImage == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please select an image.")));
      return;
    }

    if (selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a category.")),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final updatedProduct = {
        'id': widget.product['id'],
        'product_name': _nameController.text.trim(),
        'product_price': double.parse(_priceController.text),
        'product_quantity': int.parse(_quantityController.text),
        'details': _detailsController.text.trim(),
        'category': selectedCategory!,
        'image_path': selectedImage!.path,
      };

      await DBHelper.instance.updateProduct(updatedProduct);

      setState(() => isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Product updated successfully!")),
      );
      Navigator.pop(context, true);
    } catch (e) {
      setState(() => isLoading = false);
      debugPrint("Error updating product: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error updating product: $e")));
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
          child: Text(
            'Update Product',
            style: AppWidget.semiboldTextFieldStyle(),
          ),
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
                            'Update the product Image',
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
                          'Product Name',
                          'Name required',
                        ),
                        const SizedBox(height: 10),
                        _buildTextField(
                          _priceController,
                          'Price',
                          'Price required',
                          isNumber: true,
                        ),
                        const SizedBox(height: 10),
                        _buildTextField(
                          _quantityController,
                          'Quantity',
                          'Quantity required',
                          isNumber: true,
                        ),
                        const SizedBox(height: 10),
                        _buildCategoryDropdown(),
                        const SizedBox(height: 10),
                        _buildDescriptionField(),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: updateProductToDB,
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
                            'Update Product',
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
          value: selectedCategory,
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
          onChanged: (val) => setState(() => selectedCategory = val),
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
