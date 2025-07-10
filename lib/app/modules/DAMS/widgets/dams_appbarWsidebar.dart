import 'package:flutter/material.dart';
import 'package:sufi_one/app/theme/color_constant.dart';

class DamsAppbarwsidebar extends StatelessWidget
    implements PreferredSizeWidget {
  const DamsAppbarwsidebar({super.key, this.title = const Text('Register')});

  final Widget title;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.blue[900],
      centerTitle:
          false, // Consider making this configurable in the constructor if needed
      toolbarHeight: 50,
      automaticallyImplyLeading:
          false, //  Important:  We'll add our own leading.
      title: Row(
        children: [
          const Text(
            "DAMS",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      leading: IconButton(
        //  Add the menu icon button here
        icon: const Icon(Icons.menu, color: Colors.white),
        onPressed: () {
          // Use the Scaffold's key to open the drawer
          Scaffold.of(context).openDrawer();
        },
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
