import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProductsScreen extends StatefulWidget {
  final String token;

  ProductsScreen({required this.token});

  @override
  _ProductsScreenState createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  List<dynamic> products = [];
  bool _isLoading = false;
  int _currentPage = 1;
  int _totalPages = 1;

  Future<void> _fetchProducts({int page = 1}) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:4000/products?page=$page'),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          products = data['data'];
          _currentPage = data['page'];
          _totalPages = data['lastPage'];
          _isLoading = false;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar produtos.')),
        );
      }
    } catch (e) {
      debugPrint('Erro ao buscar produtos: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao conectar ao servidor.')),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  Widget _buildPaginationControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        ElevatedButton(
          onPressed: _currentPage > 1 ? () => _fetchProducts(page: _currentPage - 1) : null,
          child: Text('Anterior'),
        ),
        Text('Página $_currentPage de $_totalPages'),
        ElevatedButton(
          onPressed: _currentPage < _totalPages ? () => _fetchProducts(page: _currentPage + 1) : null,
          child: Text('Próxima'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Produtos')),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: products.isEmpty
                      ? Center(child: Text('Nenhum produto encontrado.'))
                      : ListView.builder(
                          itemCount: products.length,
                          itemBuilder: (context, index) {
                            final product = products[index];
                            return Card(
                              margin: EdgeInsets.all(8.0),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Imagem do produto
                                    product['imageUrl'] != null
                                        ? Image.network(
                                            product['imageUrl'],
                                            height: 100,
                                            width: 100,
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) =>
                                                Icon(Icons.image_not_supported),
                                          )
                                        : Container(
                                            height: 100,
                                            width: 100,
                                            color: Colors.grey[300],
                                            child: Icon(Icons.image_not_supported),
                                          ),
                                    SizedBox(width: 16),
                                    // Informações do produto
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            product['name'],
                                            style: TextStyle(
                                                fontSize: 18, fontWeight: FontWeight.bold),
                                          ),
                                          SizedBox(height: 8),
                                          Text(product['description']),
                                          SizedBox(height: 8),
                                          Text(
                                            'Preço: R\$ ${product['price']}',
                                            style: TextStyle(
                                                color: Colors.green, fontWeight: FontWeight.bold),
                                          ),
                                          Text(
                                              'Estoque: ${product['stockQuantity']} unidades'),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
                _buildPaginationControls(),
              ],
            ),
    );
  }
}
