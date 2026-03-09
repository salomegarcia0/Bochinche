import 'package:bochinche_app/sources/reports/reports_logic.dart';
import 'package:bochinche_app/sources/user_profile/user_profile_logic.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:bochinche_app/styles/NavBar.dart';
import 'package:bochinche_app/styles/BochincheAppBar.dart';
import 'package:flutter/material.dart';

class OrgProfile extends StatelessWidget {
  const OrgProfile({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(
    drawer: Navbar(),
    appBar: BochincheAppBar(),
    body: OrgProfileView(),
  );
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
    final String targetUser = userToReport ?? "";
    if (targetUser.isEmpty) {
      return const Center(child: Text("Usuario no especificado"));
    }

    return FutureBuilder<List<dynamic>>(
      future: Future.wait([
        _profileLogic.chargeProfileOrg(targetUser),
        _profileLogic.checkIfFollowing(
          FirebaseAuth.instance.currentUser!.uid,
          targetUser,
        ),
      ]),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final userData = snapshot.data![0] as Map<String, dynamic>?;
        isFollowing ??= snapshot.data![1] as bool;

        if (userData == null) {
          return const Center(child: Text("Usuario no encontrado"));
        }

        return Column(
          children: [
            const SizedBox(height: 20),
            CircleAvatar(
              radius: 40,
              backgroundImage: userData['profileImageUrl'] != null
                  ? NetworkImage(userData['profileImageUrl'])
                  : null,
              child: userData['profileImageUrl'] == null
                  ? const Icon(Icons.person)
                  : null,
            ),
            Text(
              userData['nombre'] ?? 'Usuario',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            ElevatedButton(
              onPressed: () async {
                setState(() => isFollowing = !isFollowing!);
                await _profileLogic.followOrganizer(
                  FirebaseAuth.instance.currentUser!.uid,
                  targetUser,
                  isFollowing!,
                );
              },
              child: Text(isFollowing! ? "Seguido" : "Seguir"),
            ),
          ],
        );
      },
    );
  }
}
