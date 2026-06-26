import 'package:flutter/material.dart';
import 'package:pertemuan10_2306038/models/product_model.dart';
// import 'package:pertemuan10_2306038/pages/product_detail_page.dart';
import 'package:pertemuan10_2306038/widgets/product_card.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'dart:typed_data';

class ProductPage extends StatefulWidget {
  const ProductPage({super.key});

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  //
  List<ProductModel> products = [];

  Future<void> loadProducts() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? productList = prefs.getStringList('products') ?? [];
    setState(() {
      products = productList
          .map((item) => ProductModel.fromJson(item))
          .toList();
    });
  }

  Future<void> saveProducts() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> productList = products.map((item) => item.toJson()).toList();
    await prefs.setStringList('products', productList);
  }

  Future<void> addProduct(ProductModel product) async {
    setState(() {
      products.add(product);
    });
    await saveProducts();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Produk Berhasil Ditambahkan")),
    );
  }

  Future<void> updateProduct(int index, ProductModel product) async {
    setState(() {
      products[index] = product;
    });
    await saveProducts();
  }

  Future<void> deleteProduct(int index) async {
    setState(() {
      products.removeAt(index);
    });
    await saveProducts();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Produk Berhasil Dihapus")));
  }

  // methode convert gambar
  Future<String> convertImageToBase64(XFile image) async{
    Uint8List bytes = await image.readAsBytes();

    return base64Encode(bytes);
  }

  //showform
  void showForm({ProductModel? product, int? index}) {
    final _formKey = GlobalKey<FormState>();
    TextEditingController nameController = TextEditingController(
      text: product?.name ?? "",
    );
    TextEditingController descriptionController = TextEditingController(
      text: product?.description ?? "",
    );
    TextEditingController priceController = TextEditingController(
      text: product?.price.toString() ?? "",
    );
    TextEditingController imgController = TextEditingController(
      text: product?.image ?? '',
    );

    XFile? selectedImage;
    final ImagePicker picker = ImagePicker();

    // methode ambil gambar dari galeri
    Future<void> pickImage(StateSetter setDialogState) async{
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);

      print(image);
      if (image != null) {
        setDialogState((){
          selectedImage = image;
          imgController.text = image.path;
        });
      }
      print(selectedImage?.path);
    }

    Widget buildPreviewImage(){
      if (selectedImage != null) {
        return FutureBuilder<Uint8List>(
          future: selectedImage!.readAsBytes(),
          builder: (context, snapshot) {
            //loading ketika upload gambar
            if (!snapshot.hasData){
              return const CircularProgressIndicator();
            }

            return Image.memory(
              snapshot.data!,
              width: 150,
              height: 150,
              fit: BoxFit.cover,
            );
          }  
        );
      }

      if (product?.image.isNotEmpty ?? false) {
        return Image.memory(
          base64Decode(product!.image),
          width: 150,
          height: 150,
          fit: BoxFit.cover,
        );
      }
      return const SizedBox.shrink();
    }

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(product == null ? "Tambah Produk" : "Edit Produk"),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "Nama"),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Nama tidak boleh kosong';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: "Deskripsi"),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Deskripsi tidak boleh kosong';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: priceController,
                decoration: const InputDecoration(labelText: "Harga"),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Harga tidak boleh kosong';
                  }
                  if (int.tryParse(value.trim()) == null) {
                    return 'Harga harus berupa angka';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20,),
              ElevatedButton.icon(
                onPressed: () => pickImage(setDialogState), 
                icon: Icon(Icons.image),
                label: const Text("Pilih Gambar"),
              ),
              const SizedBox(height: 20,),
              buildPreviewImage(),
              const SizedBox(height: 20,)
            ],
          ),
      ),

      actions: [
        ElevatedButton(
          onPressed: () async {
            if (_formKey.currentState?.validate() ?? false) {
              // Tentukan gambar yang akan disimpan
              String imageBase64 = '';
              if (selectedImage != null) {
                // Convert gambar baru ke base64
                imageBase64 = await convertImageToBase64(
                  selectedImage!);
              } else if (product != null && product.image.isNotEmpty) {
                // Gunakan gambar lama jika edit dan tidak ada gambar baru
                imageBase64 = product.image;
              }

              final newProduct = ProductModel(
                name: nameController.text,
                description: descriptionController.text,
                price: int.parse(priceController.text.trim()),
                image: imageBase64
              );
              if (product == null) {
                addProduct(newProduct);
              } else {
                updateProduct(index!, newProduct);
              }
              Navigator.pop(context);
            }
          },
          child: Text(product == null ? "Simpan" : "Pembaruan"),
        ),
      ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    loadProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Product Page',
          style: TextStyle(
            color: Color.fromARGB(255, 255, 255, 255),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 20, 115, 224),
        leading: IconButton(
          icon: const Icon(
            Icons.chevron_left,
            color: Color.fromARGB(255, 255, 255, 255),
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Container(
        margin: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: products.isEmpty
                  ? const Center(child: Text("Belum ada produk"))
                  : ListView.builder(
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        final product = products[index];

                        return ProductCard(
                          product: product,
                          onDelete: () => deleteProduct(index),
                          onEdit: () => showForm(product: product, index: index),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: showForm,
        child: const Icon(Icons.add),
      ),
    );
  }
}