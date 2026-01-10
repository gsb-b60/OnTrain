import 'package:flutter/material.dart';
import 'package:ontrain/core/constrants/app_colors.dart';
import 'package:ontrain/data/object/pt.dart';

class PTListpage extends StatelessWidget {
  const PTListpage({super.key, required this.pts});

  final List<PT> pts;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Container(
          //   child: Column(
          //     children: [
          //       Text("Doctor"),
          //       Text("Find your PT"),
          //       TextField(),
          //       Row(
          //         children: [
          //           IconButton.outlined(
          //             icon: Icon(Icons.line_weight),
          //             onPressed: () => {},
          //           ),
          //           IconButton.outlined(
          //             icon: Icon(Icons.line_weight),
          //             onPressed: () => {},
          //           ),
          //           IconButton.outlined(
          //             icon: Icon(Icons.line_weight),
          //             onPressed: () => {},
          //           ),
          //           IconButton.outlined(
          //             icon: Icon(Icons.line_weight),
          //             onPressed: () => {},
          //           ),
          //           IconButton.outlined(
          //             icon: Icon(Icons.line_weight),
          //             onPressed: () => {},
          //           ),
          //         ],
          //       ),
          //       Row(
          //         children: [
          //           Text("Popular PT"),
          //           ElevatedButton(onPressed: () {}, child: Text("A - Z")),
          //           ElevatedButton(onPressed: () {}, child: Text("Filter")),
          //           Spacer(),
          //           GestureDetector(
          //             onTap: () => {},
          //             child: Text(
          //               "Top Rating",
          //               style: TextStyle(
          //                 color: AppColors.aquaTeal,
          //                 decoration: TextDecoration.underline,
          //               ),
          //             ),
          //           ),
          //         ],
          //       ),
          //       Divider(thickness: 1, color: Colors.grey),
          //       ListView.builder(
          //         shrinkWrap: true,
          //         itemCount: pts.length,
          //         itemBuilder: (context, index) {
          //           return Column(
          //             children: [
          //               Container(
          //                 child: Row(
          //                   children: [
          //                     CircleAvatar(
          //                       backgroundImage: AssetImage(
          //                         "assets/PXL_20251014_011048644~2.jpg",
          //                       ),
          //                     ),
          //                     Column(
          //                       crossAxisAlignment: CrossAxisAlignment.start,
          //                       children: [
          //                         Text(pts[index].name),
          //                         Text(pts[index].Pnum),
          //                         Text("Specialties: Weight Loss, Muscle Gain"),
          //                         Text("Experience: 5 years"),
          //                         Row(
          //                           children: [
          //                             ElevatedButton(
          //                               onPressed: () {},
          //                               child: Text("info"),
          //                             ),
          //                             Spacer(),
          //                             IconButton(
          //                               onPressed: () {},
          //                               icon: Icon(
          //                                 Icons.schedule,
          //                                 color: AppColors.aquaTeal,
          //                               ),
          //                             ),
          //                             IconButton(
          //                               onPressed: () {},
          //                               icon: Icon(
          //                                 Icons.question_mark,
          //                                 color: AppColors.aquaTeal,
          //                               ),
          //                             ),
          //                             IconButton(
          //                               onPressed: () {},
          //                               icon: Icon(
          //                                 Icons.schedule,
          //                                 color: AppColors.aquaTeal,
          //                               ),
          //                             ),
          //                           ],
          //                         ),
          //                       ],
          //                     ),
          //                   ],
          //                 ),
          //               ),
          //               Divider(thickness: 1, color: Colors.grey),
          //             ],
          //           );
          //         },
          //       ),
          //     ],
          //   ),
          // ),
        ],
      ),
    );
  }
}