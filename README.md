# 📱 Mercado Autônomo

Um aplicativo Flutter para gerenciamento e exibição de produtos de mercado autônomo, com funcionalidades de autenticação, navegação por abas e integração com backend.

## ✨ Funcionalidades

- Login e registro de usuários.
- Listagem de produtos com imagens, preços e estoque.
- Paginação de produtos com filtros (nome, categoria, família).
- Perfil do usuário com visualização de dados pessoais.
- Navegação entre telas por meio de barra inferior.

## 🛠️ Tecnologias Utilizadas

- **Frontend:** [Flutter](https://flutter.dev)
- **Backend:** Node.js com NestJS (para APIs)
- **Banco de Dados:** PostgreSQL
- **Armazenamento de Imagens:** AWS S3

## 📦 Estrutura do Projeto

lib/ ├── features/ │ ├── auth/ │ │ ├── screens/ │ │ │ ├── login_screen.dart │ │ │ ├── register_screen.dart │ ├── profile/ │ │ ├── screens/ │ │ │ ├── profile_screen.dart │ ├── products/ │ │ ├── screens/ │ │ │ ├── products_screen.dart ├── main.dart


## 🚀 Como Executar o Projeto

1. **Clone o repositório:**
   ```bash
   git clone https://github.com/SEU_USUARIO/flutter-marketplace-app.git
   cd flutter-marketplace-app

2. **Instale as dependências do Flutter:**

    ```bash
    flutter pub get
    ```
    
3. **Inicie o emulador ou conecte um dispositivo:** Certifique-se de que um emulador Android/iOS ou dispositivo físico esteja configurado.

4. **Execute o projeto:**

    ```bash
    flutter run
    ```

⚙️ Configurações Necessárias
Backend API: Certifique-se de que o backend esteja rodando localmente em http://10.0.2.2 (Android Emulator) ou http://localhost (para iOS ou browser).
Variáveis de Ambiente: Configure URLs da API, se necessário, no código do aplicativo.

🛡️ Licença
Este projeto está licenciado sob a licença MIT. Consulte o arquivo LICENSE para mais informações.