import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class ProfileScreen extends StatefulWidget {
  final String token;

  ProfileScreen({required this.token});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic> profileData = {};
  bool _isLoading = true;

  Future<void> _fetchProfile() async {
    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:3000/auth/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${widget.token}',
        },
      );

      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');
      debugPrint('Token para profile: ${widget.token}');

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        setState(() {
          profileData = data;
          _isLoading = false;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao buscar perfil. Faça login novamente.')),
        );
        Navigator.pushReplacementNamed(context, '/login');
      }
    } catch (e) {
      debugPrint('Erro durante a requisição: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao conectar ao servidor. Tente novamente.')),
      );
    }
  }

  String _formatDate(String date) {
    try {
      final parsedDate = DateTime.parse(date);
      return DateFormat('dd/MM/yyyy').format(parsedDate);
    } catch (e) {
      debugPrint('Erro ao formatar a data: $e');
      return date; 
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Perfil'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Dados Pessoais',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    initialValue: '${profileData['firstName']} ${profileData['lastName']}',
                    decoration: InputDecoration(labelText: 'Nome Completo'),
                    readOnly: true,
                  ),
                  TextFormField(
                    initialValue: profileData['email'],
                    decoration: InputDecoration(labelText: 'Email'),
                    readOnly: true,
                  ),
                  TextFormField(
                    initialValue: _formatDate(profileData['birthDate']),
                    decoration: InputDecoration(labelText: 'Data de Nascimento'),
                    readOnly: true,
                  ),
                  TextFormField(
                    initialValue: profileData['cpfOrCnpj'],
                    decoration: InputDecoration(labelText: 'CPF/CNPJ'),
                    readOnly: true,
                  ),
                  TextFormField(
                    initialValue: profileData['phoneNumber'],
                    decoration: InputDecoration(labelText: 'Telefone'),
                    readOnly: true,
                  ),
                  SizedBox(height: 32),
                  Text(
                    'Endereço',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),
                  if (profileData['addresses'] != null && profileData['addresses'].isNotEmpty)
                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: profileData['addresses'].length,
                      itemBuilder: (context, index) {
                        final address = profileData['addresses'][index];
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextFormField(
                              initialValue: address['street'],
                              decoration: InputDecoration(labelText: 'Rua'),
                              readOnly: true,
                            ),
                            TextFormField(
                              initialValue: address['number'],
                              decoration: InputDecoration(labelText: 'Número'),
                              readOnly: true,
                            ),
                            if (address['complement'] != null &&
                                address['complement'].isNotEmpty)
                              TextFormField(
                                initialValue: address['complement'],
                                decoration: InputDecoration(labelText: 'Complemento'),
                                readOnly: true,
                              ),
                            TextFormField(
                              initialValue: address['neighborhood'],
                              decoration: InputDecoration(labelText: 'Bairro'),
                              readOnly: true,
                            ),
                            TextFormField(
                              initialValue: '${address['city']} - ${address['state']}',
                              decoration: InputDecoration(labelText: 'Cidade/Estado'),
                              readOnly: true,
                            ),
                            TextFormField(
                              initialValue: address['postalCode'],
                              decoration: InputDecoration(labelText: 'CEP'),
                              readOnly: true,
                            ),
                            SizedBox(height: 16),
                          ],
                        );
                      },
                    ),
                ],
              ),
            ),
    );
  }
}
