import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:remisse_arequipa_driver/authentication/login_screen.dart';
import 'package:remisse_arequipa_driver/global.dart';
import 'package:remisse_arequipa_driver/pages/assign_route_page.dart';
import 'package:remisse_arequipa_driver/pages/create_client_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  TextEditingController nameTextEditingController = TextEditingController();
  TextEditingController phoneTextEditingController = TextEditingController();
  TextEditingController emailTextEditingController = TextEditingController();
  TextEditingController carTextEditingController = TextEditingController();

  setDriverInfo() {
    setState(() {
      nameTextEditingController.text = driverName;
      phoneTextEditingController.text = driverPhone;
      emailTextEditingController.text = FirebaseAuth.instance.currentUser!.email.toString();
      carTextEditingController.text = "$carNumber - $carColor - $carModel";
    });
  }

  @override
  void initState() {
    super.initState();
    setDriverInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mi Perfil"),
        backgroundColor: brandColor,
        centerTitle: true,
        elevation: 4,
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height - AppBar().preferredSize.height,
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Imagen de perfil
                CircleAvatar(
                  radius: 60,
                  backgroundImage: NetworkImage(driverPhoto),
                  backgroundColor: Colors.grey.shade200,
                ),

                const SizedBox(height: 24),

                // Campo para el nombre
                _buildProfileField(
                  controller: nameTextEditingController,
                  label: "Nombre",
                  icon: Icons.person,
                ),

                const SizedBox(height: 16),

                // Campo para el teléfono
                _buildProfileField(
                  controller: phoneTextEditingController,
                  label: "Teléfono",
                  icon: Icons.phone_android_outlined,
                ),

                const SizedBox(height: 16),

                // Campo para el correo electrónico
                _buildProfileField(
                  controller: emailTextEditingController,
                  label: "Correo Electrónico",
                  icon: Icons.email,
                ),

                const SizedBox(height: 16),

                // Campo para la información del vehículo
                _buildProfileField(
                  controller: carTextEditingController,
                  label: "Información del Vehículo",
                  icon: Icons.drive_eta_rounded,
                ),

                const SizedBox(height: 32),

                // Botón de cerrar sesión
                ElevatedButton.icon(
                  onPressed: () {
                    FirebaseAuth.instance.signOut();
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (c) => const LoginScreen()));
                  },
                  icon: const Icon(Icons.logout),
                  label: const Text("Cerrar Sesión"),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                    backgroundColor: Colors.redAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Botón para asignar ruta
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (c)=> const AssignRoutePage()));
                  },
                  icon: const Icon(Icons.map),
                  label: const Text("Asignar Ruta"),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                    backgroundColor: brandColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Botón para crear cliente
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (c)=> const CreateClientPage()));
                  },
                  icon: const Icon(Icons.person_add),
                  label: const Text("Crear Cliente"),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                    backgroundColor: brandColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
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

  Widget _buildProfileField({
  required TextEditingController controller,
  required String label,
  required IconData icon,
}) {
  return Stack(
    children: [
      TextField(
        controller: controller,
        textAlign: TextAlign.left,
        enabled: false,
        style: const TextStyle(fontSize: 14, color: Colors.black),
        decoration: InputDecoration(
          filled: true,
          fillColor: const Color.fromARGB(192, 255, 225, 180),
          prefixIcon: Icon(icon, color: brandColor),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 24),
        ),
      ),
      Positioned(
        left: 43, // Ajusta esto según la posición deseada
        top: 0, // Ajusta la posición vertical
        child: Container(
          color: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black,
              fontWeight: FontWeight.w700,
              
              
            ),
          ),
        ),
      ),
    ],
  );
}

}
