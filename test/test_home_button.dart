// import 'package:flutter/material.dart';
// import 'package:playlistmaster/states/my_navigation_button_state.dart';
// import 'package:playlistmaster/widgets/floating_button/quick_action.dart';
// import 'package:playlistmaster/widgets/floating_button/quick_action_menu.dart';
// import 'package:provider/provider.dart';

// void main() {
//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return ChangeNotifierProvider(
//       create: (context) => MyNavigationButtonState(),
//       child: MaterialApp(
//         home: Scaffold(
//           appBar: AppBar(title: Text('Soccer Ball Widget')),
//           body: Center(
//             child: QuickActionMenu(
//               backgroundColor: Colors.white,
//               icon: Icons.sports_soccer_rounded,
//               onTap: () {},
//               actions: [
//                 QuickAction(
//                   icon: Icons.sports_baseball_rounded,
//                   onTap: () {
//                     print('baseball');
//                   },
//                 ),
//                 QuickAction(
//                   icon: Icons.sports_football_rounded,
//                   onTap: () {
//                     print('football');
//                   },
//                 ),
//                 QuickAction(
//                   icon: Icons.sports_soccer_rounded,
//                   onTap: () {
//                     print('soccer');
//                   },
//                 ),
//               ],
//               child: Container(
//                 color: Colors.blue,
//                 width: 100,
//                 height: 100,
//                 child: Text('text'),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
