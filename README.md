# Bochinche_app

##  Branches

    This branch is only to develoup the map
    When you`re gonna pull this branch, type in the terminal "flutter pub get", as the dependeces have changed to use the map

## Commands for development

flutter doctor      # Para verificar el estado del flutter 
flutter clean       # Limpiar todas las dependencias
flutter pub get     # Para instalar (o reinstalar) dependencias
flutter run         # Iniciar el programa


## Structure

lib/
 ├── styles/          # Estilos globales, temas, utilidades de red
 ├── features/      # Cada funcionalidad grande
 │    ├── auth/     # Login, Register
 │    ├── map/      # Mapa y marcadores
 │    ├── events/   # Detalle del evento, creación
 |    ├── profile/  # Detalles y edición del Perfil 
 ├── data/          # Modelos de datos y servicios (Firebase)
 └── main.dart

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
