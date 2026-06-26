import 'package:flutter/material.dart';
import 'package:pertemuan10_2306038/models/product_model.dart';
import 'package:pertemuan10_2306038/widgets/product_card.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_page.dart';
import 'product_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _username = '';
  List<ProductModel> products = [];
  int totalProducts = 0;
  // late Future<String> _usernameFuture;

  @override
  void initState() {
    super.initState();
    getUser();
    loadProducts();
  }

  Future<void> loadProducts() async {
    // Simulasi delay untuk memuat data
    final prefs = await SharedPreferences.getInstance();
    List<String> productList = prefs.getStringList('products') ?? [];
    totalProducts = productList.length;

    setState(() {
      products = productList.reversed
          .take(3)
          .map((item) => ProductModel.fromJson(item))
          .toList();
    });
  }

  Future<String> getUser() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      _username = prefs.getString('username') ?? '';
    });
    return _username;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.clear();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 210, 254, 143),
      appBar: AppBar(
        title: const Text(
          'Home Page',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Container(
                height: 150,
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 28,
                      backgroundImage: NetworkImage(
                        'https://avatars.githubusercontent.com/u/12345678?v=4',
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hai, Selamat Datang, $_username!',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    _username,
                                    style: const TextStyle(
                                      fontSize: 22,
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  const Icon(
                                    Icons.verified,
                                    size: 20,
                                    color: Colors.green,
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 42,
                                width: 42,
                                child: ElevatedButton(
                                  onPressed: logout,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red[400],
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    elevation: 2,
                                    padding: EdgeInsets.zero,
                                  ),
                                  child: const Icon(
                                    Icons.logout,
                                    size: 24,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total Produk: $totalProducts',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => ProductPage()),
                      );
                    },
                    child: const Text('Lihat Selengkapnya'),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Expanded(
                child: products.isEmpty
                    ? const Center(
                        child: Text(
                          'Belum ada produk',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        itemCount: products.length,
                        itemBuilder: (context, index) {
                          final product = products[index];
                          return ProductCard(product: product);
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
