import 'package:flutter/material.dart';
import 'package:sufi_one/app/theme/color_constant.dart';

class SuzukiFinanceAppBarWsidebar extends StatelessWidget
    implements PreferredSizeWidget {
  const SuzukiFinanceAppBarWsidebar({
    super.key,
    this.title = const Text('Register'),
  });

  final Widget title;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.splashStart,
      centerTitle:
      false, // Consider making this configurable in the constructor if needed
      toolbarHeight: 50,
      automaticallyImplyLeading:
      false, //  Important:  We'll add our own leading.
      title: Row(
        children: [
          // Logo Suzuki
          Image.asset(
            'res/images/splashscreen2.png', // Ganti dengan logo Suzuki kamu
            height: 30,
          ),
          /*const SizedBox(width: 12),
          // Judul
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Suzuki Finance", style: AppTextStyles.appBar),
              Text('Kredit Resmi Suzuki', style: AppTextStyles.appBarSmall),
            ],
          ),*/
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
