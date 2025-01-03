import 'package:flutter/material.dart';

class FilterScreen extends StatefulWidget {
  final List<String> categories;
  final List<String> families;

  FilterScreen({required this.categories, required this.families});

  @override
  _FilterScreenState createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  late List<String> _selectedCategories;
  late List<String> _selectedFamilies;

  @override
  void initState() {
    super.initState();
    _selectedCategories = List.from(widget.categories);
    _selectedFamilies = List.from(widget.families);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Filtros'),
      ),
      body: ListView(
        padding: EdgeInsets.all(8.0),
        children: [
          ExpansionTile(
            title: Text(
              'Categorias',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            children: [
              ...['Condimentos', 'Laticínios', 'Detergentes', 'Cafés', 'Grãos', 'Sabões', 'Pães', 'Águas', 'Refrigerantes', 'Doces']
                  .map((category) {
                return CheckboxListTile(
                  title: Text(category),
                  value: _selectedCategories.contains(category),
                  onChanged: (value) {
                    setState(() {
                      value!
                          ? _selectedCategories.add(category)
                          : _selectedCategories.remove(category);
                    });
                  },
                );
              }).toList(),
            ],
          ),
          ExpansionTile(
            title: Text(
              'Famílias',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            children: [
              ...['Alimentos', 'Limpeza', 'Bebidas'].map((family) {
                return CheckboxListTile(
                  title: Text(family),
                  value: _selectedFamilies.contains(family),
                  onChanged: (value) {
                    setState(() {
                      value!
                          ? _selectedFamilies.add(family)
                          : _selectedFamilies.remove(family);
                    });
                  },
                );
              }).toList(),
            ],
          ),
          SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _selectedCategories.clear();
                      _selectedFamilies.clear();
                    });
                  },
                  child: Text('Limpar Filtros'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context, {
                      'categories': _selectedCategories,
                      'families': _selectedFamilies,
                    });
                  },
                  child: Text('Aplicar Filtros'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
