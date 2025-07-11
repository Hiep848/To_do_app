import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BottomNavigationBarCustom extends StatelessWidget {
  const BottomNavigationBarCustom({super.key});

  @override
  Widget build(BuildContext context) {
    final String location = GoRouterState.of(context).uri.toString(); 
    // lấy route bằng GetRouter 
    // VD: đang ở statistics thì location == '/statistics'
    // và nếu đang ở home thì location == '/'

    // Map route to selected index
    int selectedIndex = 0;
    if (location.startsWith('/statistics')) {
      selectedIndex = 1;
    }

    return BottomNavigationBar(
      currentIndex: selectedIndex,
      onTap: (index) {
        if (index == selectedIndex) return;

        switch (index) {
          case 0:
            context.go('/');
            break;
          case 1:
            context.go('/statistics');
            break;
        }
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Trang chủ',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.bar_chart),
          label: 'Thống kê',
        ),
      ],
      selectedItemColor: Theme.of(context).primaryColor,
      unselectedItemColor: Colors.grey,
      showUnselectedLabels: true,
    );
  }
}
