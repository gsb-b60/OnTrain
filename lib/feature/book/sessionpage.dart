import 'package:flutter/material.dart';

class SessionPage extends StatelessWidget {
  const SessionPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Stack(
            children: [
              Container(
                width: double.infinity,
                height: 65,
                child: Center(child: Text("All Appointment")),
              ),
              IconButton(onPressed: () {}, icon: Icon(Icons.arrow_back_ios)),
            ],
          ),
          Row(
            children: [
              ElevatedButton(onPressed: () {}, child: Text("Complete")),
              ElevatedButton(onPressed: () {}, child: Text("Upcoming")),
              ElevatedButton(onPressed: () {}, child: Text("Cancelled")),
            ],
          ),
    
          // Container(
          //   padding: EdgeInsets.all(8),
          //   height: 400,
          //   width: double.infinity,
          //   child: ListView.builder(
          //     itemCount: pts.length,
          //     itemBuilder: (context, index) {
          //       return Column(
          //         children: [
          //           Divider(),
          //           Column(
          //             children: [
          //               Text(pts[index].name),
          //               Text(pts[index].address),
          //               Row(
          //                 children: [
          //                   Container(
          //                     child: Row(
          //                       children: [
          //                         Icon(Icons.star),
          //                         Text(pts[index].state.toString()),
          //                       ],
          //                     ),
          //                   ),
          //                   Icon(Icons.favorite),
          //                 ],
          //               ),
          //             ],
          //           ),
          //           Row(
          //             children: [
          //               ElevatedButton(
          //                 onPressed: () {},
          //                 child: Text("Re - Book"),
          //               ),
          //               ElevatedButton(
          //                 onPressed: () {},
          //                 child: Text("Add Review"),
          //               ),
          //             ],
          //           ),
          //           Divider(),
          //         ],
          //       );
          //     },
          //   ),
          // ),
        ],
      ),
    );
  }
}