import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../widgets/main_bottom_nav.dart';

import '../controllers/riwayat_controller.dart';

class RiwayatView extends GetView<RiwayatController> {
  const RiwayatView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          Theme.of(context).scaffoldBackgroundColor,

      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF2E66E7),
        title: const Text(
          "Riwayat Assessment",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),

      body: Obx(() {

        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (controller.histories.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment:
                  MainAxisAlignment.center,
              children: const [

                Icon(
                  Icons.history,
                  size: 80,
                  color: Colors.grey,
                ),

                SizedBox(height: 15),

                Text(
                  "Belum Ada Riwayat Assessment",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                SizedBox(height: 5),

                Text(
                  "Lakukan assessment terlebih dahulu",
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [

              // =====================
              // HEADER CARD
              // =====================

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark 
                      ? Theme.of(context).cardColor 
                      : const Color(0xFFEAF4FF),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    if (Theme.of(context).brightness == Brightness.dark)
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    Row(
                      children: const [
                        Icon(
                          Icons.trending_up,
                          color: Color(0xFF2E66E7),
                        ),
                        SizedBox(width: 8),
                        Text(
                          "Perkembangan Mental",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 15),

                    Obx(() {

                      if (controller.histories.length < 2) {
                        return const Text(
                          "Belum cukup data untuk melihat perkembangan.",
                          style: TextStyle(fontSize: 14),
                        );
                      }

                      final latest =
                          controller.histories[0]["final_score"];

                      final previous =
                          controller.histories[1]["final_score"];

                      final diff = latest - previous;

                      return Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [

                          Text(
                            diff >= 0
                                ? "+$diff poin dibanding assessment sebelumnya"
                                : "$diff poin dibanding assessment sebelumnya",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: diff >= 0
                                  ? Colors.green
                                  : Colors.red,
                            ),
                          ),

                          const SizedBox(height: 8),

                          Text(
                            diff > 0
                                ? "Status: Meningkat 📈"
                                : diff < 0
                                    ? "Status: Menurun 📉"
                                    : "Status: Stabil ➖",
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      );
                    }),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              Align(
                alignment:
                    Alignment.centerLeft,
                child: Text(
                  "RIWAYAT TERBARU",
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontWeight:
                        FontWeight.bold,
                    letterSpacing: 1,
                    fontSize: 12,
                  ),
                ),
              ),

              const SizedBox(height: 15),

              Expanded(
                child: ListView.builder(
                  itemCount:
                      controller.histories.length,

                  itemBuilder:
                      (context, index) {

                    final item =
                        controller
                            .histories[index];

                    final score =
                        item["final_score"] ??
                            0;

                    final level =
                        item["level"] ??
                            "-";

                    Color statusColor;

                    if (score >= 80) {
                      statusColor =
                          Colors.green;
                    } else if (score >=
                        60) {
                      statusColor =
                          Colors.blue;
                    } else if (score >=
                        40) {
                      statusColor =
                          Colors.orange;
                    } else {
                      statusColor =
                          Colors.red;
                    }

                    return InkWell(
                      borderRadius:
                          BorderRadius
                              .circular(
                        20,
                      ),

                      onTap: () {

                        Get.toNamed(
                          '/hasil',
                          arguments: item,
                        );

                      },

                      child: Container(
                        margin:
                            const EdgeInsets
                                .only(
                          bottom: 15,
                        ),

                        padding:
                            const EdgeInsets
                                .all(
                          18,
                        ),

                        decoration:
                            BoxDecoration(
                          color:
                              Theme.of(
                                      context)
                                  .cardColor,

                          borderRadius:
                              BorderRadius
                                  .circular(
                            20,
                          ),

                          boxShadow: [
                            BoxShadow(
                              color: Colors
                                  .black
                                  .withOpacity(
                                      0.05),

                              blurRadius:
                                  12,

                              offset:
                                  const Offset(
                                      0, 4),
                            ),
                          ],
                        ),

                        child: Row(
                          children: [

                            // SCORE

                            Container(
                              width: 65,
                              height: 65,

                              decoration:
                                  BoxDecoration(
                                shape:
                                    BoxShape
                                        .circle,

                                color: statusColor
                                    .withOpacity(
                                        0.12),
                              ),

                              child: Center(
                                child: Text(
                                  "$score",

                                  style:
                                      TextStyle(
                                    fontSize:
                                        22,

                                    fontWeight:
                                        FontWeight
                                            .bold,

                                    color:
                                        statusColor,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(
                                width: 16),

                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment
                                        .start,

                                children: [

                                  Text(
                                    level,

                                    style:
                                        TextStyle(
                                      fontSize:
                                          18,

                                      fontWeight:
                                          FontWeight
                                              .bold,

                                      color:
                                          statusColor,
                                    ),
                                  ),

                                  const SizedBox(
                                      height:
                                          5),

                                  const Text(
                                    "Assessment Kesehatan Mental",
                                  ),

                                  const SizedBox(
                                      height:
                                          8),

                                  Row(
                                    children: [

                                      const Icon(
                                        Icons
                                            .calendar_today,
                                        size:
                                            14,
                                        color:
                                            Colors.grey,
                                      ),

                                      const SizedBox(
                                          width:
                                              5),

                                      Text(
                                        item["created_at"]
                                            .toString()
                                            .substring(
                                                0,
                                                10),

                                        style:
                                            const TextStyle(
                                          color:
                                              Colors.grey,

                                          fontSize:
                                              12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            const Icon(
                              Icons
                                  .arrow_forward_ios,
                              size: 18,
                              color:
                                  Colors.grey,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      }),
      bottomNavigationBar: const MainBottomNav(),
    );
  }
}