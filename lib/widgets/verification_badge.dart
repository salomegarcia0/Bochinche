import 'package:flutter/material.dart';
import 'package:bochinche_app/data/auth_service.dart'; 

class VerificationBadge extends StatelessWidget {
  final String uid;
  final double size;

  const VerificationBadge({
    super.key, 
    required this.uid, 
    this.size = 20.0, 
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<String>(
      stream: AuthService().obtenerEstadoVerificacionStream(uid),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data == 'verified') {
          return Padding(
            padding: const EdgeInsets.only(left: 4.0),
            child: Icon(Icons.verified, color: Colors.blue, size: size),
          );
        }
        
        return const SizedBox.shrink(); 
      },
    );
  }
}