import 'package:flutter/material.dart';
import 'package:ontrain/controller/ptController.dart';
import 'package:ontrain/core/constrants/app_colors.dart';
import 'package:ontrain/core/constrants/app_size.dart';
import 'package:ontrain/data/object/pt.dart';
import 'package:ontrain/feature/book/filterpage.dart';
import 'package:ontrain/feature/book/ptcvpage.dart';
import 'package:provider/provider.dart';

class PTListpage extends StatefulWidget {
  const PTListpage({super.key, this.initialSpecialty});

  /// When set (e.g. tapped from the Specialties screen), the PT list is
  /// pre-filtered to this specialty on load.
  final String? initialSpecialty;

  @override
  State<PTListpage> createState() => _PTListpageState();
}

class _PTListpageState extends State<PTListpage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = context.read<PTController>();
      controller.getPTs();
      if (widget.initialSpecialty != null) {
        controller.filterBySpecialty(widget.initialSpecialty);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            decoration: BoxDecoration(color: AppColors.aquaTeal),
            height: 200,
            child: Column(
              children: [
                Stack(
                  children: [
                    SizedBox(
                      height: 65,
                      child: Center(
                        child: Text(
                          "Personal Trainer",
                          style: TextStyle(
                            color: AppColors.light,
                            fontSize: AppSizes.semiLarge,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: Icon(
                            Icons.arrow_back_ios,
                            color: AppColors.light,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(),
                        margin: EdgeInsets.only(
                          left: 35,
                          right: 8,
                          bottom: 15,
                        ),
                        child: TextField(
                          onChanged: (value) =>
                              context.read<PTController>().filterByName(value),
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: AppColors.light,
                            hint: Text(
                              "Seach ....",
                              style: TextStyle(
                                color: AppColors.aquaTeal,
                                fontSize: AppSizes.medium,
                              ),
                            ),
                            // icon: Icon(Icons.search)
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 35),
                      child: IconButton.filled(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const Filterpage(),
                            ),
                          );
                        },
                        icon: const Icon(
                          Icons.tune,
                          color: AppColors.aquaTeal,
                        ),
                        tooltip: "Filters",
                      ),
                    ),
                  ],
                ),
                // Active specialty chip (shown when arriving from Specialties)
                Consumer<PTController>(
                  builder: (context, controller, child) {
                    final specialty = controller.currentSpecialty;
                    if (specialty == null) {
                      return const SizedBox.shrink();
                    }
                    return Padding(
                      padding: const EdgeInsets.only(
                        left: 35,
                        right: 35,
                        bottom: 12,
                      ),
                      child: Row(
                        children: [
                          Flexible(
                            child: Text(
                              "Specialty: $specialty",
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppColors.light,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              controller.filterBySpecialty(null);
                            },
                            icon: const Icon(
                              Icons.close,
                              size: 18,
                              color: AppColors.light,
                            ),
                            visualDensity: VisualDensity.compact,
                            tooltip: "Clear specialty filter",
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          // Row(
          //   children: [
          //     IconButton.outlined(
          //       icon: Icon(Icons.line_weight),
          //       onPressed: () => {},
          //     ),
          //     IconButton.outlined(
          //       icon: Icon(Icons.line_weight),
          //       onPressed: () => {},
          //     ),
          //     IconButton.outlined(
          //       icon: Icon(Icons.line_weight),
          //       onPressed: () => {},
          //     ),
          //     IconButton.outlined(
          //       icon: Icon(Icons.line_weight),
          //       onPressed: () => {},
          //     ),
          //     IconButton.outlined(
          //       icon: Icon(Icons.line_weight),
          //       onPressed: () => {},
          //     ),
          //   ],
          // ),
          // SizedBox(height: 35),
          // Container(
          //   width: double.infinity,
          //   margin: EdgeInsets.symmetric(horizontal: 35),
          //   child: Column(
          //     children: [
          //       Row(
          //         children: [
          //           Text("Sort By:"),
          //           GestureDetector(
          //             onTap: () {},
          //             child: Container(
          //               margin: EdgeInsets.symmetric(horizontal: 12),
          //               padding: EdgeInsets.all(6),
          //               decoration: BoxDecoration(
          //                 color: AppColors.aquaTeal,
          //                 borderRadius: BorderRadius.circular(16),
          //               ),
          //               child: Text(
          //                 "A - Z",
          //                 style: TextStyle(color: AppColors.light),
          //               ),
          //             ),
          //           ),
          //           GestureDetector(
          //             onTap: () {
          //               Navigator.push(
          //                 context,
          //                 MaterialPageRoute(builder: (context) => Filterpage()),
          //               );
          //             },
          //             child: Container(
          //               padding: EdgeInsets.all(6),
          //               decoration: BoxDecoration(
          //                 border: Border.all(color: AppColors.aquaTeal),
          //                 borderRadius: BorderRadius.circular(16),
          //               ),
          //               child: Text(
          //                 "Filter",
          //                 style: TextStyle(
          //                   color: AppColors.aquaTeal,
          //                   fontWeight: FontWeight.bold,
          //                 ),
          //               ),
          //             ),
          //           ),
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
          //     ],
          //   ),
          // ),
          Expanded(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 35),
              child: Consumer<PTController>(
                builder: (context, ptController, child) {
                  return ListView.builder(
                    itemCount: ptController.pts.length,
                    itemBuilder: (context, index) {
                      return Material(
                        child: InkWell(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PTCVPage(
                                pt: ptController.pts[index],
                              ),
                            ),
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  // Container(
                                  //   padding: EdgeInsets.all(12),
                                  //   child: CircleAvatar(
                                  //     radius: 52,
                                  //     backgroundImage: AssetImage(
                                  //       "assets/PXL_20251014_011048644~2.jpg",
                                  //     ),
                                  //   ),
                                  // ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        
                                        Row(
                                          children: [
                                            Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              ptController.pts[index].name,
                                              style: TextStyle(
                                                color: AppColors.aquaTeal,
                                                fontWeight: FontWeight.bold,
                                                fontSize: AppSizes.medium,
                                              ),
                                            ),
Text(
  ptController.pts[index].phoneNumber ?? '',
),
                                          ],
                                        ),
                                            Spacer(),
                          
                                            // Icon(
                                            //   Icons.schedule,
                                            //   color: AppColors.aquaTeal,
                                            // ),
                                            // Icon(
                                            //   Icons.question_mark,
                                            //   color: AppColors.aquaTeal,
                                            // ),
                                            Selector<PTController, bool>(
                                              selector: (context, controller) =>controller.pts[index].isFavorite,
                                              builder:(context, isFavorite, child) {
                                                    return GestureDetector(
                                                      onTap: () {
                                                        ptController.toggleFavorite(
                                                          index,
                                                        );
                                                      },
                                                      child: Icon(
                                                        isFavorite
                                                            ? Icons.favorite
                                                            : Icons.favorite_border,
                                                        color: AppColors.aquaTeal,
                                                      ),
                                                    );
                                                  },
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              Divider(),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
