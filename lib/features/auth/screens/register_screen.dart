import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // Controladores para informações básicas
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _cpfController = TextEditingController();
  final _birthDateController = TextEditingController();

  // Controladores para endereço
  final _postalCodeController = TextEditingController();
  final _streetController = TextEditingController();
  final _numberController = TextEditingController();
  final _complementController = TextEditingController();
  final _neighborhoodController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();

  // Controladores para senha
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  int _currentStep = 0;
  bool _isLoading = false;

  Future<void> _fetchAddress() async {
    final postalCode = _postalCodeController.text.trim();
    if (postalCode.isEmpty || postalCode.length != 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor, insira um CEP válido.')),
      );
      return;
    }

    debugPrint('Buscando endereço para o CEP: $postalCode');

    try {
      final response = await http.get(
        Uri.parse('https://viacep.com.br/ws/$postalCode/json/'),
      );

      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['erro'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('CEP não encontrado.')),
          );
        } else {
          setState(() {
            _streetController.text = data['logradouro'] ?? '';
            _neighborhoodController.text = data['bairro'] ?? '';
            _cityController.text = data['localidade'] ?? '';
            _stateController.text = data['uf'] ?? '';
          });
          debugPrint('Endereço carregado com sucesso.');
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao buscar endereço.')),
        );
      }
    } catch (e) {
      debugPrint('Erro ao buscar CEP: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao conectar ao serviço de CEP.')),
      );
    }
  }
  
  Future<void> _register() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:3000/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'firstName': _firstNameController.text,
          'lastName': _lastNameController.text,
          'email': _emailController.text,
          'password': _passwordController.text,
          'confirmPassword': _confirmPasswordController.text,
          'birthDate': _birthDateController.text,
          'phoneNumber': _phoneController.text,
          'cpfOrCnpj': _cpfController.text,
          'address': {
            'postalCode': _postalCodeController.text,
            'street': _streetController.text,
            'number': _numberController.text,
            'complement': _complementController.text,
            'neighborhood': _neighborhoodController.text,
            'city': _cityController.text,
            'state': _stateController.text,
          },
        }),
      );

      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Cadastro realizado com sucesso!')),
        );
        Navigator.pop(context);
      } else {
        final data = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? 'Falha ao registrar.')),
        );
      }
    } catch (e) {
      debugPrint('Erro durante a requisição: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao conectar ao servidor. Tente novamente.')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Cadastro')),
      body: Stepper(
        currentStep: _currentStep,
        onStepContinue: () {
          if (_currentStep == 2) {
            _register();
          } else {
            setState(() {
              _currentStep++;
            });
          }
        },
        onStepCancel: () {
          if (_currentStep > 0) {
            setState(() {
              _currentStep--;
            });
          }
        },
        steps: [
          Step(
            title: Text('Informações Básicas'),
            content: Column(
              children: [
                TextField(
                  controller: _firstNameController,
                  decoration: InputDecoration(labelText: 'Primeiro Nome'),
                ),
                TextField(
                  controller: _lastNameController,
                  decoration: InputDecoration(labelText: 'Sobrenome'),
                ),
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(labelText: 'Email'),
                ),
                TextField(
                  controller: _cpfController,
                  decoration: InputDecoration(labelText: 'CPF ou CNPJ'),
                ),
                TextField(
                  controller: _phoneController,
                  decoration: InputDecoration(labelText: 'Telefone'),
                ),
                TextField(
                  controller: _birthDateController,
                  decoration: InputDecoration(labelText: 'Data de Nascimento (dd/mm/yyyy)'),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    DateInputFormatter(),
                  ],
                ),
              ],
            ),
          ),
          Step(
            title: Text('Endereço'),
            content: Column(
              children: [
                TextField(
                  controller: _postalCodeController,
                  decoration: InputDecoration(
                    labelText: 'CEP',
                    suffixIcon: IconButton(
                      icon: Icon(Icons.search),
                      onPressed: _fetchAddress,
                    ),
                  ),
                ),
                TextField(
                  controller: _streetController,
                  decoration: InputDecoration(labelText: 'Rua'),
                ),
                TextField(
                  controller: _numberController,
                  decoration: InputDecoration(labelText: 'Número'),
                ),
                TextField(
                  controller: _complementController,
                  decoration: InputDecoration(labelText: 'Complemento'),
                ),
                TextField(
                  controller: _neighborhoodController,
                  decoration: InputDecoration(labelText: 'Bairro'),
                ),
                TextField(
                  controller: _cityController,
                  decoration: InputDecoration(labelText: 'Cidade'),
                ),
                TextField(
                  controller: _stateController,
                  decoration: InputDecoration(labelText: 'Estado'),
                ),
              ],
            ),
          ),
          Step(
            title: Text('Definir Senha'),
            content: Column(
              children: [
                TextField(
                  controller: _passwordController,
                  decoration: InputDecoration(labelText: 'Senha'),
                  obscureText: true,
                ),
                TextField(
                  controller: _confirmPasswordController,
                  decoration: InputDecoration(labelText: 'Confirmar Senha'),
                  obscureText: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Formata a data para o padrão dd/mm/yyyy
class DateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    if (text.length > 8) return oldValue;

    String formattedText = '';
    for (int i = 0; i < text.length; i++) {
      if (i == 2 || i == 4) formattedText += '/';
      formattedText += text[i];
    }

    return newValue.copyWith(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }
}