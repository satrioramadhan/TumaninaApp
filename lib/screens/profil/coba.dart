// bro aku punya web service gini
// ```
// from flask import Flask, request, jsonify
// from flask_sqlalchemy import SQLAlchemy
// from flask_bcrypt import Bcrypt
// from flask_jwt_extended import JWTManager, create_access_token, jwt_required, get_jwt_identity
// import os
// from dotenv import load_dotenv
// import requests

// # Load environment variables
// load_dotenv()

// # App Config
// app = Flask(__name__)
// app.config['SQLALCHEMY_DATABASE_URI'] = os.getenv("SQLALCHEMY_DATABASE_URI")
// app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
// app.config['JWT_SECRET_KEY'] = os.getenv("JWT_SECRET_KEY")

// # Initialize Extensions
// db = SQLAlchemy(app)
// bcrypt = Bcrypt(app)
// jwt = JWTManager(app)

// # Models
// class User(db.Model):
//     __tablename__ = 'users_apk'
//     id = db.Column(db.Integer, primary_key=True)
//     username = db.Column(db.String(255), unique=True, nullable=False)
//     email = db.Column(db.String(255), unique=True, nullable=False)
//     password = db.Column(db.String(255), nullable=False)
//     created_at = db.Column(db.DateTime, default=db.func.current_timestamp())
//     updated_at = db.Column(db.DateTime, default=db.func.current_timestamp(), onupdate=db.func.current_timestamp())

// class InputReview(db.Model):
//     __tablename__ = 'input_review'
//     id_review = db.Column(db.Integer, primary_key=True)
//     nama = db.Column(db.String(255), nullable=False)
//     tanggal = db.Column(db.DateTime, default=db.func.current_timestamp())
//     review = db.Column(db.Text, nullable=False)

// # Register Route
// @app.route('/register', methods=['POST'])
// def register():
//     data = request.get_json()
//     username = data.get('username')
//     email = data.get('email')
//     password = data.get('password')

//     if User.query.filter_by(email=email).first() or User.query.filter_by(username=username).first():
//         return jsonify({"msg": "User already exists"}), 400

//     hashed_password = bcrypt.generate_password_hash(password).decode('utf-8')
//     new_user = User(username=username, email=email, password=hashed_password)
//     db.session.add(new_user)
//     db.session.commit()

//     return jsonify({"msg": "User registered successfully"}), 201

// # Login Route
// @app.route('/login', methods=['POST'])
// def login():
//     data = request.get_json()
//     email = data.get('email')
//     password = data.get('password')

//     user = User.query.filter_by(email=email).first()

//     if not user or not bcrypt.check_password_hash(user.password, password):
//         return jsonify({"msg": "Invalid credentials"}), 401

//     access_token = create_access_token(identity=str(user.id))
//     return jsonify({"token": access_token}), 200

// # Get User Info Route
// @app.route('/user', methods=['GET'])
// @jwt_required()
// def get_user():
//     user_id = get_jwt_identity()
//     user = db.session.get(User, user_id)

//     if not user:
//         return jsonify({"msg": "User not found"}), 404

//     return jsonify({"username": user.username, "email": user.email}), 200

// # Edit User Route (Update Username, Email, Password)
// @app.route('/user', methods=['PUT'])
// @jwt_required()
// def edit_user():
//     user_id = get_jwt_identity()
//     user = db.session.get(User, user_id)

//     if not user:
//         return jsonify({"msg": "User not found"}), 404

//     data = request.get_json()

//     # Ambil data dari request
//     username = data.get('username', user.username)  # Default ke username lama jika tidak diisi
//     email = data.get('email', user.email)          # Default ke email lama jika tidak diisi
//     old_password = data.get('old_password')        # Password lama
//     new_password = data.get('new_password')        # Password baru

//     # Cek apakah username atau email sudah digunakan oleh user lain
//     if User.query.filter(User.id != user_id, User.username == username).first():
//         return jsonify({"msg": "Username already taken"}), 400

//     if User.query.filter(User.id != user_id, User.email == email).first():
//         return jsonify({"msg": "Email already taken"}), 400

//     # Jika user ingin update password
//     if old_password and new_password:
//         # Validasi password lama
//         if not bcrypt.check_password_hash(user.password, old_password):
//             return jsonify({"msg": "Old password is incorrect"}), 400

//         # Hash password baru dan update
//         hashed_new_password = bcrypt.generate_password_hash(new_password).decode('utf-8')
//         user.password = hashed_new_password

//     # Update username dan email
//     user.username = username
//     user.email = email

//     db.session.commit()
//     return jsonify({"msg": "User updated successfully"}), 200

// # Delete User Route
// @app.route('/user', methods=['DELETE'])
// @jwt_required()
// def delete_user():
//     user_id = get_jwt_identity()
//     user = db.session.get(User, user_id)

//     if not user:
//         return jsonify({"msg": "User not found"}), 404

//     db.session.delete(user)
//     db.session.commit()
//     return jsonify({"msg": "User deleted successfully"}), 200

// # Submit Sentiment Route


// @app.route('/sentiment', methods=['POST'])
// @jwt_required()
// def submit_sentiment():
//     user_id = get_jwt_identity()  # Ambil ID user dari JWT
//     data = request.get_json()

//     # Ambil data dari request JSON
//     nama = data.get('nama')  # Nama user
//     review = data.get('review')  # Review/sentimen

//     # Validasi input
//     if not nama or not review:
//         return jsonify({"msg": "Nama dan review wajib diisi"}), 400

//     # Kirim data ke endpoint web lama
//     web_lama_url = "http://tumanina.me/sentimen/add_review"  # URL endpoint web lama
//     payload = {
//         "name": nama,
//         "text": review
//     }
//     try:
//         response = requests.post(web_lama_url, json=payload)  # Kirim JSON payload ke web lama
//         if response.status_code == 200:
//             return jsonify({"msg": "Sentimen berhasil diproses", "detail": response.json()}), 200
//         else:
//             return jsonify({"msg": "Gagal memproses sentimen di web lama", "error": response.text}), 500
//     except Exception as e:
//         return jsonify({"msg": "Error connecting to web lama", "error": str(e)}), 500


// if __name__ == "__main__":
//     with app.app_context():
//         db.create_all()  # Initialize database
//     app.run(debug=True, host="0.0.0.0", port=5000)
// ```

// itu aku jadikan sebagai API nanti untuk model, btw aku udah online kan pake ngrok "https://fcea-36-68-54-156.ngrok-free.app"

// nah coba kamu cek code mobile aku dulu nih
// yang mau integrasi kan ke  flutter mobile


// lib/service/api_service.dart
// ```
// import 'dart:convert';
// import 'dart:io';
// import 'package:dio/dio.dart';
// import 'package:http/http.dart' as http;

// class ApiService {
//   final Dio _dio = Dio();

//   // URL Server Flask
//   final String BaseUrl =
//       "https://fcea-36-68-54-156.ngrok-free.app"; // Ganti jika URL berbeda
//   final String updateProfileEndpoint =
//       '/updateProfile'; // Replace with your actual endpoint
//   final String deleteAccountEndpoint = '/deleteAccount';

//   // URL dan Key API Groq
//   final String groqApiKey =
//       'yourapikey'; // Ganti dengan API Key Anda
//   final String groqBaseUrl = 'https://api.groq.com/openai/v1';
//   final String groqModel = 'llama-3.3-70b-versatile';

//   // URL API Artikel
//   final String artikelBaseUrl =
//       'hhttps://artikel-islam.netlify.app/.netlify/functions/api/ms/detail/:id_article';

//   Future<void> register(String username, String email, String password) async {
//     final url = Uri.parse('$BaseUrl/register');
//     try {
//       final response = await http.post(
//         url,
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode({
//           'username': username,
//           'email': email,
//           'password': password,
//         }),
//       );

//       if (response.statusCode == 201) {
//         print('Registration successful');
//       } else {
//         throw Exception('Registration failed: ${response.body}');
//       }
//     } catch (e) {
//       print('Error during registration: $e');
//       throw e;
//     }
//   }


//   Future<Map<String, dynamic>> login(String email, String password) async {
//     final url = Uri.parse('$BaseUrl/login');
//     try {
//       final response = await http.post(
//         url,
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode({
//           'email': email,
//           'password': password,
//         }),
//       );

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         print('Login successful: ${data['username']}');
//         return data; // Mengembalikan data pengguna
//       } else {
//         throw Exception('Login failed: ${response.body}');
//       }
//     } catch (e) {
//       print('Error during login: $e');
//       throw e;
//     }
//   }

//   /// Fungsi untuk mengirim frame ke server Flask
//   Future<Map<String, dynamic>> sendFrame(File imageFile) async {
//     try {
//       final request = http.MultipartRequest(
//         'POST',
//         Uri.parse('$BaseUrl/detect-movement'),
//       );
//       request.files.add(
//         await http.MultipartFile.fromPath('frame', imageFile.path),
//       );

//       final response = await request.send();
//       if (response.statusCode == 200) {
//         final respStr = await response.stream.bytesToString();
//         return json.decode(respStr);
//       } else {
//         return {'error': 'Failed to detect movement: ${response.statusCode}'};
//       }
//     } catch (e) {
//       return {'error': 'Failed to connect to server: $e'};
//     }
//   }

//   Future<void> submitFeedback(String name, String feedback, String date) async {
//     final url = Uri.parse('$BaseUrl/sentimen/add_review'); // Update endpoint sesuai backend
//     try {
//       final response = await http.post(
//         url,
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode({
//           'name': name, // Key sesuai dengan backend Flask
//           'text': feedback, // Pastikan key 'text' sesuai
//         }),
//       );

//       if (response.statusCode == 200) {
//         print('Feedback berhasil dikirim: ${response.body}');
//       } else {
//         throw Exception('Gagal mengirim feedback: ${response.body}');
//       }
//     } catch (e) {
//       print('Error saat mengirim feedback: $e');
//       throw e;
//     }
//   }


//   // Method to update profile (username and profile image)
//   Future<void> updateProfile(String username, File? profileImage) async {
//     try {
//       // Prepare the data for the request
//       FormData formData = FormData.fromMap({
//         'username': username,
//         if (profileImage != null)
//           'profile_image': await MultipartFile.fromFile(profileImage.path),
//       });

//       // Send POST request to update profile
//       final response = await _dio.post(
//         '$BaseUrl$updateProfileEndpoint',
//         data: formData,
//       );

//       // Check for success
//       if (response.statusCode == 200) {
//         print('Profile updated successfully!');
//       } else {
//         print('Failed to update profile: ${response.statusCode}');
//       }
//     } catch (e) {
//       print('Error updating profile: $e');
//     }
//   }

//   // Method to delete account
//   Future<void> deleteAccount() async {
//     try {
//       final response = await _dio.post('$BaseUrl$deleteAccountEndpoint');

//       if (response.statusCode == 200) {
//         print('Account deleted successfully!');
//       } else {
//         print('Failed to delete account: ${response.statusCode}');
//       }
//     } catch (e) {
//       print('Error deleting account: $e');
//     }
//   }

//   /// Fungsi untuk mengirim pesan ke Groq API
//   Future<String> sendMessageToGroqAPI(String userMessage) async {
//     final url = Uri.parse('$groqBaseUrl/chat/completions');
//     try {
//       final response = await http.post(
//         url,
//         headers: {
//           'Authorization': 'Bearer $groqApiKey',
//           'Content-Type': 'application/json',
//         },
//         body: jsonEncode({
//           "messages": [
//             {
//               "role": "system",
//               "content":
//                   "Tumabot: Asisten Islami berbahasa Indonesia. Jawaban selalu Islami, sopan, dan bermanfaat. Jangan pernah membuat respon dengan bahasa inggris. Ini aplikasi Tumanina: Tuntunan Mandiri Niat dan Ibadah"
//             },
//             {"role": "user", "content": userMessage}
//           ],
//           "model": groqModel,
//           "temperature": 0.6,
//           "max_tokens": 1024,
//           "top_p": 0.7
//         }),
//       );

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         return data['choices'][0]['message']['content'];
//       } else {
//         throw Exception(
//           'Failed to fetch response: ${response.statusCode}, ${response.body}',
//         );
//       }
//     } on SocketException {
//       return "Maaf, sepertinya Anda sedang offline. Pastikan koneksi internet Anda aktif untuk menggunakan Tumabot.";
//     } on Exception catch (e) {
//       return "Maaf, terjadi masalah teknis: $e. Silakan coba lagi nanti.";
//     }
//   }

//   /// Fungsi untuk mengambil artikel dari API Artikel
//   Future<List<Map<String, dynamic>>> fetchArticles() async {
//     final url = Uri.parse(artikelBaseUrl);
//     final response = await http.get(url);

//     if (response.statusCode == 200) {
//       final data = json.decode(response.body);

//       if (data.containsKey('data') && data['data'] is List) {
//         return List<Map<String, dynamic>>.from(data['data']);
//       } else {
//         throw Exception(
//             'Data articles tidak ditemukan atau tidak dalam format yang diharapkan');
//       }
//     } else {
//       throw Exception('Failed to load articles');
//     }
//   }

// }

// ```

// screens/fitur_login/login_screen.dart
// ```
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import '../../services/api_service.dart';
// import '../home_screen.dart';
// import 'register_screen.dart';

// class LoginScreen extends StatefulWidget {
//   const LoginScreen({super.key});

//   @override
//   _LoginScreenState createState() => _LoginScreenState();
// }

// class _LoginScreenState extends State<LoginScreen> {
//   final TextEditingController emailController = TextEditingController();
//   final TextEditingController passwordController = TextEditingController();
//   bool isPasswordVisible = false;
//   bool isLoading = false; // Untuk menampilkan indikator loading

//   Widget _buildTextField({
//     required String labelText,
//     required TextEditingController controller,
//     bool isPassword = false,
//     void Function()? toggleVisibility,
//   }) {
//     return TextField(
//       controller: controller,
//       obscureText: isPassword && !isPasswordVisible,
//       decoration: InputDecoration(
//         labelText: labelText,
//         border: const OutlineInputBorder(
//           borderRadius: BorderRadius.all(Radius.circular(12)),
//         ),
//         enabledBorder: const OutlineInputBorder(
//           borderSide: BorderSide(color: Color(0xFF2DDCBE)),
//           borderRadius: BorderRadius.all(Radius.circular(4)),
//         ),
//         focusedBorder: const OutlineInputBorder(
//           borderSide: BorderSide(color: Color(0xFF2DDCBE), width: 2.0),
//           borderRadius: BorderRadius.all(Radius.circular(4)),
//         ),
//         suffixIcon: isPassword
//             ? IconButton(
//                 icon: Icon(
//                   isPasswordVisible ? Icons.visibility : Icons.visibility_off,
//                 ),
//                 onPressed: toggleVisibility,
//               )
//             : null,
//       ),
//       style: const TextStyle(fontSize: 16),
//     );
//   }

//   Future<void> _login() async {
//     final email = emailController.text.trim();
//     final password = passwordController.text.trim();

//     if (email.isEmpty || password.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text("Email dan kata sandi harus diisi!"),
//           backgroundColor: Colors.red,
//         ),
//       );
//       return;
//     }

//     setState(() {
//       isLoading = true;
//     });

//     try {
//       final response = await ApiService().login(email, password);

//       // Simpan token JWT di shared_preferences
//       final prefs = await SharedPreferences.getInstance();
//       await prefs.setString('token', response['token']);

//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text("Login berhasil!"),
//           backgroundColor: Colors.green,
//         ),
//       );

//       // Navigasi ke HomeScreen
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (context) => const HomeScreen()),
//       );
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text("Login gagal: $e"),
//           backgroundColor: Colors.red,
//         ),
//       );
//     } finally {
//       setState(() {
//         isLoading = false;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: Center(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.symmetric(horizontal: 30),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const SizedBox(height: 50),
//               Row(
//                 children: [
//                   Image.asset(
//                     'assets/logo/Logo1.png', // Logo PNG
//                     width: 50,
//                     height: 50,
//                   ),
//                   const SizedBox(width: 10),
//                   const Text(
//                     'Tumanina',
//                     style: TextStyle(
//                       fontSize: 20,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.black87,
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 30),
//               const Text(
//                 'Masuk ke akun Anda',
//                 style: TextStyle(
//                   fontSize: 22,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.black87,
//                 ),
//               ),
//               const SizedBox(height: 10),
//               const Text(
//                 'Masukkan email dan kata sandi Anda untuk masuk',
//                 style: TextStyle(
//                   fontSize: 14,
//                   color: Colors.black54,
//                 ),
//               ),
//               const SizedBox(height: 30),
//               _buildTextField(
//                 labelText: 'Email',
//                 controller: emailController,
//               ),
//               const SizedBox(height: 20),
//               _buildTextField(
//                 labelText: 'Kata sandi',
//                 controller: passwordController,
//                 isPassword: true,
//                 toggleVisibility: () {
//                   setState(() {
//                     isPasswordVisible = !isPasswordVisible;
//                   });
//                 },
//               ),
//               const SizedBox(height: 30),
//               SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   onPressed: isLoading ? null : _login, // Disable tombol saat loading
//                   style: ElevatedButton.styleFrom(
//                     foregroundColor: Colors.white,
//                     backgroundColor: const Color(0xFF2DDCBE),
//                     padding: const EdgeInsets.symmetric(vertical: 12),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     elevation: 5,
//                   ),
//                   child: isLoading
//                       ? const CircularProgressIndicator(color: Colors.white)
//                       : const Text(
//                           'Masuk',
//                           style: TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                 ),
//               ),
//               const SizedBox(height: 20),
//               const Center(
//                 child: Text(
//                   'Atau',
//                   style: TextStyle(color: Colors.black54),
//                 ),
//               ),
//               const SizedBox(height: 10),
//               SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton.icon(
//                   onPressed: () {},
//                   style: ElevatedButton.styleFrom(
//                     foregroundColor: Colors.black87,
//                     backgroundColor: Colors.white,
//                     side: const BorderSide(color: Color(0xFF2DDCBE)),
//                     padding: const EdgeInsets.symmetric(vertical: 12),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                   ),
//                   icon: Image.asset(
//                     'assets/logo/google.png',
//                     width: 20,
//                     height: 20,
//                   ),
//                   label: const Text('Lanjutkan dengan Google'),
//                 ),
//               ),
//               const SizedBox(height: 20),
//               Center(
//                 child: GestureDetector(
//                   onTap: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                           builder: (context) => const RegisterScreen()),
//                     );
//                   },
//                   child: const Text(
//                     'Belum memiliki akun? Daftar',
//                     style: TextStyle(
//                       color: Color(0xFF004C7E),
//                       fontSize: 14,
//                     ),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 20),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// ```

// lib/screens/fitur_login/register_screen.dart
// ```
// import 'package:flutter/material.dart';
// import '../../services/api_service.dart';
// import '../home_screen.dart';
// import 'package:flutter/gestures.dart';

// class RegisterScreen extends StatefulWidget {
//   const RegisterScreen({super.key});

//   @override
//   _RegisterScreenState createState() => _RegisterScreenState();
// }

// class _RegisterScreenState extends State<RegisterScreen> {
//   final TextEditingController nameController = TextEditingController();
//   final TextEditingController emailController = TextEditingController();
//   final TextEditingController passwordController = TextEditingController();
//   final TextEditingController confirmPasswordController = TextEditingController();
//   bool isPasswordVisible = false;
//   bool isChecked = false;

//   @override
//   void dispose() {
//     // Jangan lupa membersihkan controller saat widget dihapus
//     nameController.dispose();
//     emailController.dispose();
//     passwordController.dispose();
//     confirmPasswordController.dispose();
//     super.dispose();
//   }

//   void _showErrorDialog(BuildContext context, String title,
//       {String message = "Terjadi kesalahan. Silakan coba lagi."}) {
//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(15),
//           ),
//           title: Text(
//             title,
//             style: const TextStyle(fontWeight: FontWeight.bold),
//           ),
//           content: Text(
//             message,
//             style: const TextStyle(fontSize: 14),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.pop(context);
//               },
//               child: const Text("Tutup"),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   void _showTerms(BuildContext context, String title) {
//     showDialog(
//       context: context,
//       builder: (context) {
//         return Dialog(
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(15),
//           ),
//           child: Container(
//             width: MediaQuery.of(context).size.width * 0.8,
//             padding: const EdgeInsets.all(20),
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [const Color(0xFF2DDCBE), const Color(0xFF004C7E)],
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//               ),
//               borderRadius: BorderRadius.circular(15),
//             ),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text(
//                       title,
//                       style: const TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.white,
//                       ),
//                     ),
//                     IconButton(
//                       icon: const Icon(Icons.close, color: Colors.white),
//                       onPressed: () => Navigator.pop(context),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 15),
//                 Expanded(
//                   child: SingleChildScrollView(
//                     child: Text(
//                       title == "Syarat dan Ketentuan"
//                           ? """
// Syarat dan Ketentuan

// 1. Pendahuluan
//    Selamat datang di aplikasi Tumanina. Dengan menggunakan aplikasi ini, Anda menyetujui untuk mematuhi syarat dan ketentuan yang berlaku.

// 2. Akses dan Penggunaan Aplikasi
//    - Anda bertanggung jawab atas informasi yang Anda masukkan dalam aplikasi.
//    - Dilarang menggunakan aplikasi ini untuk aktivitas yang melanggar hukum atau mengganggu pengguna lain.

// 3. Akun dan Keamanan
//    - Anda bertanggung jawab atas kerahasiaan akun Anda, termasuk kata sandi.
//    - Kami tidak bertanggung jawab atas kerugian akibat penyalahgunaan akun Anda.

// 4. Konten Pengguna
//    - Semua data yang diunggah pengguna akan dijaga kerahasiaannya sesuai dengan Kebijakan Privasi.
//    - Kami berhak menghapus konten yang melanggar ketentuan atau merugikan pihak lain.

// 5. Perubahan Layanan
//    - Kami dapat memperbarui atau menghentikan fitur aplikasi tanpa pemberitahuan sebelumnya.

// 6. Hak Kekayaan Intelektual
//    - Semua konten dalam aplikasi ini, termasuk teks, gambar, dan logo, dilindungi oleh hak kekayaan intelektual.
//    - Dilarang menggunakan atau menyalin konten aplikasi tanpa izin tertulis dari pihak pengembang.

// 7. Hukum yang Berlaku
//    Syarat dan Ketentuan ini diatur sesuai dengan hukum yang berlaku di Indonesia.
//                       """
//                           : """
// Kebijakan Privasi

// 1. Informasi yang Dikumpulkan
//    - Kami mengumpulkan informasi pribadi, seperti nama, email, dan data lainnya yang relevan untuk penggunaan aplikasi.
//    - Data ini digunakan untuk meningkatkan layanan kami dan memastikan pengalaman pengguna yang optimal.

// 2. Penggunaan Informasi
//    - Informasi pribadi Anda hanya digunakan untuk keperluan internal dan tidak akan dibagikan kepada pihak ketiga tanpa izin Anda.
//    - Data dapat digunakan untuk memberikan pengalaman yang lebih personal di aplikasi.

// 3. Keamanan Data
//    - Kami menggunakan teknologi terkini untuk melindungi data Anda dari akses yang tidak sah.
//    - Namun, kami tidak dapat menjamin keamanan absolut dari informasi yang Anda berikan.

// 4. Hak Pengguna
//    - Anda berhak mengakses, mengubah, atau menghapus informasi pribadi Anda kapan saja melalui pengaturan akun.
//    - Hubungi kami jika Anda memiliki pertanyaan terkait privasi atau permintaan penghapusan data.

// 5. Penyimpanan Data
//    - Data Anda akan disimpan selama akun Anda aktif. Setelah akun dinonaktifkan, data Anda akan dihapus sesuai kebijakan kami.

// 6. Perubahan Kebijakan
//    - Kami dapat memperbarui Kebijakan Privasi ini dari waktu ke waktu. Perubahan akan diberitahukan melalui aplikasi atau email terdaftar Anda.

// 7. Hubungi Kami
//    Jika Anda memiliki pertanyaan atau masalah terkait privasi, hubungi kami melalui email di support@tumanina.com.
//                       """,
//                       style: const TextStyle(
//                         fontSize: 12,
//                         color: Colors.white70,
//                         height: 1.5,
//                       ),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 15),
//                 Align(
//                   alignment: Alignment.centerRight,
//                   child: ElevatedButton(
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.white,
//                       foregroundColor: Colors.blueAccent,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                     ),
//                     onPressed: () => Navigator.pop(context),
//                     child: const Text("Tutup"),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: Center(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.symmetric(horizontal: 30),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               GestureDetector(
//                 onTap: () {
//                   Navigator.pop(context);
//                 },
//                 child: const Row(
//                   children: [
//                     Icon(Icons.arrow_back, color: Colors.black87),
//                     SizedBox(width: 8),
//                     Text(
//                       "Kembali ke halaman login",
//                       style: TextStyle(
//                         color: Colors.black87,
//                         fontSize: 14,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 30),
//               const Text(
//                 "Daftar Akun Baru",
//                 style: TextStyle(
//                   fontSize: 22,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.black87,
//                 ),
//               ),
//               const SizedBox(height: 20),
//               TextField(
//                 controller: nameController,
//                 decoration: const InputDecoration(
//                   labelText: "Nama",
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.all(Radius.circular(12)),
//                   ),
//                   enabledBorder: OutlineInputBorder(
//                     borderSide: BorderSide(color: Color(0xFF2DDCBE)),
//                   ),
//                   focusedBorder: OutlineInputBorder(
//                     borderSide:
//                         BorderSide(color: Color(0xFF2DDCBE), width: 2.0),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 20),
//               TextField(
//                 controller: emailController,
//                 decoration: const InputDecoration(
//                   labelText: "Email",
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.all(Radius.circular(12)),
//                   ),
//                   enabledBorder: OutlineInputBorder(
//                     borderSide: BorderSide(color: Color(0xFF2DDCBE)),
//                   ),
//                   focusedBorder: OutlineInputBorder(
//                     borderSide:
//                         BorderSide(color: Color(0xFF2DDCBE), width: 2.0),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 20),
//               TextField(
//                 controller: passwordController,
//                 obscureText: !isPasswordVisible,
//                 decoration: InputDecoration(
//                   labelText: "Kata sandi",
//                   border: const OutlineInputBorder(
//                     borderRadius: BorderRadius.all(Radius.circular(16)),
//                   ),
//                   enabledBorder: const OutlineInputBorder(
//                     borderSide: BorderSide(color: Color(0xFF2DDCBE)),
//                   ),
//                   focusedBorder: const OutlineInputBorder(
//                     borderSide:
//                         BorderSide(color: Color(0xFF2DDCBE), width: 2.0),
//                   ),
//                   suffixIcon: IconButton(
//                     icon: Icon(
//                       isPasswordVisible
//                           ? Icons.visibility
//                           : Icons.visibility_off,
//                     ),
//                     onPressed: () {
//                       setState(() {
//                         isPasswordVisible = !isPasswordVisible;
//                       });
//                     },
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 20),
//               TextField(
//                 controller: confirmPasswordController,
//                 obscureText: true,
//                 decoration: const InputDecoration(
//                   labelText: "Konfirmasi kata sandi",
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.all(Radius.circular(12)),
//                   ),
//                   enabledBorder: OutlineInputBorder(
//                     borderSide: BorderSide(color: Color(0xFF2DDCBE)),
//                   ),
//                   focusedBorder: OutlineInputBorder(
//                     borderSide:
//                         BorderSide(color: Color(0xFF2DDCBE), width: 2.0),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 20),
//               Row(
//                 children: [
//                   Checkbox(
//                     value: isChecked,
//                     onChanged: (value) {
//                       setState(() {
//                         isChecked = value!;
//                       });
//                     },
//                     activeColor: const Color(0xFF2DDCBE),
//                   ),
//                   Expanded(
//                     child: RichText(
//                       text: TextSpan(
//                         text:
//                             "Dengan ini saya membaca, memahami, dan menyetujui ",
//                         style: const TextStyle(
//                             color: Colors.black87, fontSize: 12),
//                         children: [
//                           TextSpan(
//                             text: "Syarat dan Ketentuan",
//                             style: const TextStyle(
//                                 color: Color(0xFF004C7E),
//                                 fontWeight: FontWeight.bold),
//                             recognizer: TapGestureRecognizer()
//                               ..onTap = () {
//                                 _showTerms(context, "Syarat dan Ketentuan");
//                               },
//                           ),
//                           const TextSpan(text: " serta "),
//                           TextSpan(
//                             text: "Kebijakan Privasi",
//                             style: const TextStyle(
//                                 color: Color(0xFF004C7E),
//                                 fontWeight: FontWeight.bold),
//                             recognizer: TapGestureRecognizer()
//                               ..onTap = () {
//                                 _showTerms(context, "Kebijakan Privasi");
//                               },
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 20),
//               SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   onPressed: isChecked
//                       ? () async {
//                           if (nameController.text.isEmpty ||
//                               emailController.text.isEmpty ||
//                               passwordController.text.isEmpty ||
//                               confirmPasswordController.text.isEmpty) {
//                             ScaffoldMessenger.of(context).showSnackBar(
//                               const SnackBar(
//                                 content: Text("Harap isi semua kolom!"),
//                                 backgroundColor: Colors.red,
//                               ),
//                             );
//                             return;
//                           }

//                           if (passwordController.text !=
//                               confirmPasswordController.text) {
//                             ScaffoldMessenger.of(context).showSnackBar(
//                               const SnackBar(
//                                 content: Text("Kata sandi tidak cocok!"),
//                                 backgroundColor: Colors.red,
//                               ),
//                             );
//                             return;
//                           }

//                           try {
//                             final apiService = ApiService();
//                             await apiService.register(
//                               nameController.text,
//                               emailController.text,
//                               passwordController.text,
//                             );

//                             ScaffoldMessenger.of(context).showSnackBar(
//                               const SnackBar(
//                                 content: Text("Registrasi berhasil"),
//                                 backgroundColor: Colors.green,
//                               ),
//                             );

//                             Navigator.pushReplacement(
//                               context,
//                               MaterialPageRoute(
//                                   builder: (context) => const HomeScreen()),
//                             );
//                           } catch (e) {
//                             _showErrorDialog(
//                               context,
//                               "Registrasi Gagal",
//                               message:
//                                   "Terjadi kesalahan saat registrasi. Silakan coba lagi nanti.",
//                             );
//                           }
//                         }
//                       : null,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: const Color(0xFF2DDCBE),
//                     foregroundColor: Colors.white,
//                     padding: const EdgeInsets.symmetric(vertical: 14),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                   ),
//                   child: const Text("Daftar"),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }


// ```

// lib/screens/profil/edit_profile_screen.dart
// ```
// import 'package:flutter/material.dart';
// import '../../services/api_service.dart';
// import '../fitur_login/login_screen.dart';

// class EditProfileScreen extends StatefulWidget {
//   final String initialUsername;
//   final String initialEmail;

//   const EditProfileScreen({
//     super.key,
//     required this.initialUsername,
//     required this.initialEmail,
//   });

//   @override
//   _EditProfileScreenState createState() => _EditProfileScreenState();
// }

// class _EditProfileScreenState extends State<EditProfileScreen> {
//   final TextEditingController _usernameController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();

//   @override
//   void initState() {
//     super.initState();
//     _usernameController.text = widget.initialUsername;
//   }

//   void _saveProfile() async {
//     String updatedUsername = _usernameController.text.trim();
//     String updatedPassword = _passwordController.text.trim();

//     if (updatedUsername.isNotEmpty && updatedPassword.isNotEmpty) {
//       await ApiService().updateProfile(updatedUsername, null);

//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: const Text("Profil berhasil diperbarui"),
//           backgroundColor: const Color(0xFF2DDCBE),
//         ),
//       );

//       Navigator.pop(context);
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: const Text("Harap isi semua kolom"),
//           backgroundColor: Colors.red,
//         ),
//       );
//     }
//   }

//   void _deleteAccount() async {
//     bool? confirmDelete = await showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: const Text("Konfirmasi Hapus Akun"),
//           content: const Text("Apakah Anda yakin ingin menghapus akun Anda? Tindakan ini tidak dapat dibatalkan."),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.of(context).pop(false),
//               child: const Text("Batal"),
//             ),
//             TextButton(
//               onPressed: () => Navigator.of(context).pop(true),
//               child: const Text("Hapus", style: TextStyle(color: Colors.red)),
//             ),
//           ],
//         );
//       },
//     );

//     if (confirmDelete == true) {
//       await ApiService().deleteAccount(); // Implementasi di ApiService untuk menghapus akun

//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: const Text("Akun berhasil dihapus"),
//           backgroundColor: Colors.red,
//         ),
//       );

//       Navigator.pushAndRemoveUntil(
//         context,
//         MaterialPageRoute(builder: (context) => const LoginScreen()),
//         (Route<dynamic> route) => false,
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         title: const Text(
//           "Edit Profil",
//           style: TextStyle(color: Colors.white),
//         ),
//         backgroundColor: const Color(0xFF004C7E),
//         elevation: 0,
//         iconTheme: const IconThemeData(color: Colors.white),
//       ),
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const Text(
//                 "Perbarui Informasi",
//                 style: TextStyle(
//                   fontSize: 20,
//                   fontWeight: FontWeight.bold,
//                   color: Color(0xFF004C7E),
//                 ),
//               ),
//               const SizedBox(height: 20),
//               TextField(
//                 controller: _usernameController,
//                 decoration: InputDecoration(
//                   labelText: "Username",
//                   labelStyle: const TextStyle(color: Color(0xFF004C7E)),
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                   focusedBorder: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(10),
//                     borderSide: const BorderSide(color: Color(0xFF004C7E)),
//                   ),
//                   fillColor: Colors.white,
//                   filled: true,
//                 ),
//               ),
//               const SizedBox(height: 16),
//               TextField(
//                 controller: _passwordController,
//                 decoration: InputDecoration(
//                   labelText: "Password",
//                   labelStyle: const TextStyle(color: Color(0xFF004C7E)),
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                   focusedBorder: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(10),
//                     borderSide: const BorderSide(color: Color(0xFF004C7E)),
//                   ),
//                   fillColor: Colors.white,
//                   filled: true,
//                 ),
//                 obscureText: true,
//               ),
//               const SizedBox(height: 20),
//               Center(
//                 child: ElevatedButton(
//                   onPressed: _saveProfile,
//                   style: ElevatedButton.styleFrom(
//                     foregroundColor: Colors.white, backgroundColor: const Color(0xFF2DDCBE),
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 40,
//                       vertical: 15,
//                     ),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(30),
//                     ),
//                   ),
//                   child: const Text(
//                     "Simpan Perubahan",
//                     style: TextStyle(fontSize: 16),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 20),
//               Center(
//                 child: TextButton(
//                   onPressed: _deleteAccount,
//                   child: const Text(
//                     "Hapus Akun",
//                     style: TextStyle(color: Colors.red, fontSize: 16),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
// ```


// lib/screens/profil/feedback_form.dart
// ```
// import 'package:flutter/material.dart';
// import '../../services/api_service.dart';

// class FeedbackForm extends StatefulWidget {
//   const FeedbackForm({super.key});

//   @override
//   _FeedbackFormState createState() => _FeedbackFormState();
// }

// class _FeedbackFormState extends State<FeedbackForm> {
//   final _formKey = GlobalKey<FormState>();
//   final TextEditingController _nameController = TextEditingController();
//   final TextEditingController _feedbackController = TextEditingController();

//   void _submitFeedback() async {
//     final name = _nameController.text.trim();
//     final feedback = _feedbackController.text.trim();

//     if (_formKey.currentState?.validate() ?? false) {
//       try {
//         await ApiService().submitFeedback(name, feedback, DateTime.now().toIso8601String());
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text("Feedback berhasil dikirim"),
//             backgroundColor: Color(0xFF2DDCBE),
//           ),
//         );
//         Navigator.pop(context); // Kembali ke halaman sebelumnya
//       } catch (e) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text("Gagal mengirim feedback: $e"),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Form(
//       key: _formKey,
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           TextFormField(
//             controller: _nameController,
//             decoration: InputDecoration(
//               labelText: 'Nama',
//               labelStyle: const TextStyle(color: Color(0xFF004C7E)),
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(10),
//               ),
//               focusedBorder: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(10),
//                 borderSide: const BorderSide(color: Color(0xFF004C7E)),
//               ),
//               fillColor: Colors.white,
//               filled: true,
//             ),
//             validator: (value) {
//               if (value == null || value.isEmpty) {
//                 return 'Nama tidak boleh kosong';
//               }
//               return null;
//             },
//           ),
//           const SizedBox(height: 12),
//           TextFormField(
//             controller: _feedbackController,
//             maxLines: 4,
//             decoration: InputDecoration(
//               labelText: 'Tulis Ulasan Anda',
//               labelStyle: const TextStyle(color: Color(0xFF004C7E)),
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(10),
//               ),
//               focusedBorder: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(10),
//                 borderSide: const BorderSide(color: Color(0xFF004C7E)),
//               ),
//               fillColor: Colors.white,
//               filled: true,
//             ),
//             validator: (value) {
//               if (value == null || value.isEmpty) {
//                 return 'Feedback tidak boleh kosong';
//               }
//               return null;
//             },
//           ),
//           const SizedBox(height: 16),
//           Center(
//             child: ElevatedButton(
//               onPressed: _submitFeedback,
//               style: ElevatedButton.styleFrom(
//                 foregroundColor: Colors.white,
//                 backgroundColor: const Color(0xFF2DDCBE),
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 40,
//                   vertical: 15,
//                 ),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(30),
//                 ),
//               ),
//               child: const Text('Kirim', style: TextStyle(fontSize: 16)),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
// ```



// kayaknyauntuk sentimen dan edit profile masih belum ikutin API nya 