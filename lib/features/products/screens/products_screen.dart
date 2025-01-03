import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'filter_screen.dart';

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

  String _searchName = '';
  List<String> _selectedCategories = [];
  List<String> _selectedFamilies = [];

  final TextEditingController _searchController = TextEditingController();

  Future<void> _fetchProducts({int page = 1}) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final queryParams = {
        'page': page.toString(),
        if (_searchName.isNotEmpty) 'name': _searchName,
        if (_selectedCategories.isNotEmpty) 'category': _selectedCategories.join(','),
        if (_selectedFamilies.isNotEmpty) 'family': _selectedFamilies.join(','),
      };

      final uri = Uri.http('10.0.2.2:4000', '/products', queryParams);

      final response = await http.get(
        uri,
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

  Widget _buildSearchBar() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Buscar por nome',
              border: OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: Icon(Icons.clear),
                onPressed: () {
                  setState(() {
                    _searchName = '';
                    _searchController.clear();
                  });
                  _fetchProducts(page: 1);
                },
              ),
            ),
          ),
        ),
        IconButton(
          icon: Icon(Icons.search),
          onPressed: () {
            setState(() {
              _searchName = _searchController.text;
            });
            _fetchProducts(page: 1);
          },
        ),
      ],
    );
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
      appBar: AppBar(
        title: Text('Produtos'),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: () async {
              final filters = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FilterScreen(
                    categories: _selectedCategories,
                    families: _selectedFamilies,
                  ),
                ),
              );

              if (filters != null) {
                setState(() {
                  _selectedCategories = filters['categories'];
                  _selectedFamilies = filters['families'];
                });
                _fetchProducts(page: 1);
              }
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => _fetchProducts(page: 1),
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: _buildSearchBar(),
                  ),
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
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              product['name'],
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            SizedBox(height: 8),
                                            Text(product['description']),
                                            SizedBox(height: 8),
                                            Text(
                                              'Preço: R\$ ${product['price']}',
                                              style: TextStyle(
                                                color: Colors.green,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Text('Estoque: ${product['stockQuantity']} unidades'),
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
      ),
    );
  }
}
