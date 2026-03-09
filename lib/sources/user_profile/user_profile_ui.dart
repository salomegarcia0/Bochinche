import 'package:bochinche_app/sources/reports/reports_logic.dart';
import 'package:bochinche_app/sources/user_profile/user_profile_logic.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bochinche_app/styles/NavBar.dart';
import 'package:bochinche_app/styles/BochincheAppBar.dart';
import 'package:flutter/material.dart';

class OrgProfile extends StatelessWidget {
  const OrgProfile({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      drawer: Navbar(),
      appBar: BochincheAppBar(),
      body: OrgProfileView(),
    );
  }
}

class OrgProfileView extends StatefulWidget {
  const OrgProfileView({super.key});

  @override
  State<OrgProfileView> createState() => _OrgProfileViewState();
}

class _OrgProfileViewState extends State<OrgProfileView> {
  final UserProfileLogic _profileLogic = UserProfileLogic();
  bool? isFollowing;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Perfil del usuario",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: Future.wait([
          _profileLogic.chargeProfileOrg(userToReport!),
          _profileLogic.checkIfFollowing(
            FirebaseAuth.instance.currentUser!.uid,
            userToReport!,
          ),
        ]),
        builder: (context, snapshot) {
          if (snapshot.hasError || !snapshot.hasData) {
            return const Center(child: Text("No se pudo cargar el perfil"));
          }

          final userData = snapshot.data![0] as Map<String, dynamic>?;
          final bool followingStatus = snapshot.data![1] as bool;

          if (userData == null)
            return const Center(child: Text("Usuario no encontrado"));

          isFollowing ??= followingStatus;

          return Column(
            children: [
              const SizedBox(height: 20),
              CircleAvatar(
                radius: 40,
                backgroundColor:
                    Colors.grey[200], // Color de fondo mientras carga
                backgroundImage: userData['profileImageUrl'] != null
                    ? NetworkImage(userData['profileImageUrl'])
                    : const NetworkImage("https://via.placeholder.com/150"),
                // Para manejar el error en Web sin que se rompa:
                onBackgroundImageError: (exception, stackTrace) {
                  // Aquí puedes registrar el error si quieres
                },
                child: userData['profileImageUrl'] == null
                    ? const Icon(
                        Icons.person,
                        size: 40,
                      ) // Icono si no hay imagen
                    : null,
              ),
              const SizedBox(height: 10),
              Text(
                userData['nombre'] ?? 'Usuario',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              Text(userData['email'] ?? ''),
              Text(userData['telefono'] ?? ''),
              const SizedBox(height: 10),
              Visibility(
                visible: FirebaseAuth.instance.currentUser!.uid != userToReport,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isFollowing!
                        ? Colors.grey[300]
                        : Colors.deepPurple,
                    foregroundColor: isFollowing! ? Colors.black : Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  onPressed: () async {
                    setState(() {
                      isFollowing = !isFollowing!;
                    });

                    await _profileLogic.followOrganizer(
                      FirebaseAuth.instance.currentUser!.uid,
                      userToReport!,
                      isFollowing!,
                    );
                  },
                  icon: Icon(isFollowing! ? Icons.check : Icons.person_add),
                  label: Text(isFollowing! ? "Seguido" : "Seguir"),
                ),
              ),
              SizedBox(height: 3),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.star, color: Colors.amber),
                  FutureBuilder<double>(
                    future: _profileLogic.getStarsUser(userToReport!),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Text(" ...");
                      }
                      if (snapshot.hasError) {
                        return Text(" Error");
                      }

                      double estrellas = snapshot.data ?? 0.0;
                      return Text(" ${estrellas.toStringAsFixed(2)}");
                    },
                  ),
                ],
              ),

              const Divider(),
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  "Eventos creados",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),

              Expanded(
                child: FutureBuilder<List<QueryDocumentSnapshot>>(
                  future: _profileLogic.getEventsByOrganizer(userToReport!),
                  builder: (context, eventSnapshot) {
                    if (eventSnapshot.hasError ||
                        !eventSnapshot.hasData ||
                        eventSnapshot.data!.isEmpty) {
                      return const Center(
                        child: Text("Sin eventos disponibles."),
                      );
                    }

                    final events = eventSnapshot.data!;

                    return ListView.builder(
                      itemCount: events.length,
                      itemBuilder: (context, index) {
                        var eventData =
                            events[index].data() as Map<String, dynamic>;

                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: ListTile(
                            leading: const Icon(
                              Icons.event,
                              color: Colors.deepPurple,
                            ),
                            title: Text(
                              eventData['name'] ?? 'Evento sin título',
                            ),
                            subtitle: Text(
                              "Rating: ${eventData['stars'] ?? '0'}",
                            ),
                            trailing: const Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
