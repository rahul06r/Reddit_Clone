import 'package:flutter/material.dart';
import 'package:routemaster/routemaster.dart';

class ModToolsScreen extends StatelessWidget {
  final String name;
  const ModToolsScreen({super.key, required this.name});

  void goToModToolsPage(BuildContext context) {
    Routemaster.of(context).push('/edit-community/$name');
  }

  void goToEditMembersPAge(BuildContext context) {
    Routemaster.of(context).push('/edit-members/$name');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Mod Tools"),
      ),
      body: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.add_moderator),
            onTap: () => goToEditMembersPAge(context),
            title: const Text(
              "Add Moderators",
            ),
          ),
          ListTile(
            leading: const Icon(Icons.edit),
            onTap: () => goToModToolsPage(context),
            title: const Text(
              "Edit Community",
            ),
          ),
        ],
      ),
    );
  }
}
