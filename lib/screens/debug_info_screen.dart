// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:school_manager/database/exam_database.dart';
import 'package:school_manager/database/hw_database.dart';
import 'package:school_manager/database/subject_database.dart';
import 'package:school_manager/models/homeworks/homework_id_model.dart';
import 'package:school_manager/models/priority_model.dart';
import 'package:school_manager/services/secure_storage.dart';
import 'package:school_manager/tasks_app.dart';
import 'package:school_manager/utils/show_adaptive_dialog.dart';

class DbInfoScreen extends StatelessWidget {
  DbInfoScreen({super.key});

  late final exams = examsDb.getDatabase();
  late final hws = homeworksDb.getDatabase();
  late final subjects = subjectsDb.getDatabase();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: ListView(
          children: [
            FloatingActionButton.extended(
              onPressed: () {
                HomeworksDatabase().deleteAllFromDisk();
                SubjectDatabase().deleteAllFromDisk();
                ExamDatabase().deleteAllFromDisk();
              },
              label: const Text('delete from disk'),
              icon: const Icon(Icons.bug_report),
            ),
            const Divider(),
            const Text('SECURE STORAGE'),
            FilledButton(
              onPressed: () async {
                await SecureStorage().write(SecureStorage.bakaRefreshTokenKey,
                    'eyJhbGciOiJSU0EtT0FFUCIsImVuYyI6IkEyNTZDQkMtSFM1MTIiLCJraWQiOiJQejFrUDNuSEw5a0NaUTZBTlRZbnJ3IiwidHlwIjoib2lfcmVmdCtqd3QiLCJjdHkiOiJKV1QifQ.m3h8fHuY5pRJKfpFs9IOfGK1Fl7IWMZfq0PxumTsi26E_Z2SsXx7mJZ4ypIM9Y-MjNtdUrZXXtzfUnKE_h7vP0E0C7rPrRuM5USVnWSy2QQg9hyG32uAeMODTSEiKsID8pBa9uuzsgjD66ZpBDMsk6C21aQaQwjLO7rdaitgESFvtdozpmSdPuCgO1Q3LHfvJn0zCkc0HXrP1mdpIDIrxkDcgav4NFfRkFfQDyMV9XYtKwit0SGAe03gzxcRJQ9dfD5eJWmglymS9_UHGTqMSfrWI6x_gxM7Ak1S_E0mJPh9Z0hHQ26BEakO8vT4BoyvpxBbrVdEwMpqPr7-DH2p-Q.TpsvQrdH1e3k_ZtXZ_K0Pg.KV9F9Rh6W_hU8J75ZHaoE0EsUANpFDf7OhDZeg76s5s8JKlPaO1LJsRis3j_tcHiG9hRk9h3hiCoGN3yvzJOrjvg0FBr189I6FfhAR876hUcaJtB7G3C4DOItWTTqSfVb04bxcn4ZNcOZ06WyY946Q_ZGLwLM03IKG4r4sjEPCm08s0ACdy4MC-DgIVpEIanrSlwKUURYYANi3ANMAGXci8Alh-I0M3Lbg9plKWhQcer5ToSp5z-jMCzGxl8uXn9f8LoH6AjT6hRm9Kv1KMQDz9o7e5VslEx3aBqhs5uGvPdB1NISaBCMKInfaHvqWPy9OWN0b_TWXwY51DL_HHVkNNs5rGHcV8bkXP3mQvmwqo1A_c-FBJdNf-B3jI1oE88Nd6xwGNvTXxq6_gC52ODasew2EIlvFOn-f2UII2obQARPsQKwWPtf7J6VPOCp0mjKiqFYuOn_H3MJ_Gdw3jY1o2f8e45TC8TRb8qGaUGcQTKrr-F4m5K2giXepvvqmnlhTUH2hz67tfsdoeRU6o857q7jD4WUnYEs_fav0FLckMHnyxvtNXkZxhhxLI5p_d5ShGLKC91LQdvxttsmnPQX0cTSzJaFX9UV6G9KXDIPlWYq8x_HwvvVK4hUmEZ2pK74X0YMx3oi3Mqjx2AIDZJ-5ROcg_FkFFWnV_ty8EU7CUrcDF4pXXsLTsJ7W-rV6H2tFgCSvsbdmWElAsAM7QCEVXuPSDA--PDPmedg1cotB9lK4zuxkBPzkg1ASLBSt6z9JrJZ9bpBR3J822DKphvGyjXRi0C-zKAMHYP7LWWptC2En9rsW-mnG7U0zhfHzMUO2HLVVD9oq4sazHacoML6hu6ZXLbfnIa656KEU68TofUi5oV3_fut6jj-wbmwvmf23LwLHLC3CNRtuAd4eKm6_kxWOQknWFOoqOa-DMdhNfrx8dwCNlPUkfyhkjOZ_IIJgYCgj23hJNq9TkZPOhuo8WNgffPPGV83-hJ0Ljrs60OrgmM0Acgdon8v6oyLC7vxZnEoKAhYliTYG0heZJrHq4DdzgPCaIBUBDfsVsVk2aQn4-9ElMrl3-lxieqBi5M85ZxYlwAJreD-M7JBse_L6wvnDSa1t3rl2WS9x5F0c_2VdFSmDVgeHU6AjNXBHEz6A7w7-OAUnsgVWbEtzAq0jMN9ns5FN3DBAuG2GGmcw0-Gz0CyW1FqFQ7NqBBv_4D8E9REFcvyBE1W5iki6GAwffsSGbcx8XeB_Pv3TkwNDNItYdOEpLkU1NTFH4XL8g3aqDpY24kzA0diSThqXtrbqWqYm72BmuJyPLZzrZ8J1EpzOye42zNAwLclTRejs_HoP0UcKOklBzK506Z-XX-8tNL88MOHnOSWLNNv-OfisJhh1ZpgI8Yu9oWG5Wk1r0cl3Zq24WdlQOuH8OzBV3g7NHNGdA8-p7gu1UXZ0MdTdATqCu7rsPsXMPTzy-S1byzsUEjbceoDVDZQ0-a9Wt-qOdivqEyP3rOoMmHmhGeEiREdRPlMMSgOST_SOb8LVjvgWmGOyOT89-xE72CbvemhDiv-BNCmRNZogy4p9PbSL5twc1-hFzBUBKGYlRoYZM82vO95yYKRmUps6XaOyWperCbZROXnhZTdR4TUmlF2QJElyRKDUZ1Nu9mCvYXLFjilO-jWQ7GJZJr5kNZFLIgSyRTbess6A_JkCcfeVk103wCWdyLla-Y4LeGa61IMNBUdykcOJ7PKePtS2mvH2middjZDsKYQ068D_SH_vVwSvYTdZG7J4XMFyftssXG6BV69n2tjI9mBbeZTS0tuUmvt4zb5dGqvRZ1VQ6SyP_Ka6H0af3zTLnVUypsJ90hQLgmE719mKWLEkxIdJYN0TvkEURAOXyhApKAdaWEQxRJH6uJgO4J6pWD93a5SSl194Aw9hTlfiQekhBnPXZrSLJXuFW_df71qx5kjvVqhl4fTtWyyy3H_nuYzAn-k-Jw82fvVeTo8thMucsqBYGMVvTX224FjhfsFRRcK2jsrtAh6Te4Nd3QCI51oEV5-rdSpoqk9uj0n4U2OTjy3H9hk133KETmMR4uyx8Mmjv51fWvnxq-wRqOMpBzC7EsyHCqUxoBMIjjKMMwvXzGVTNaoiSkNK_5k077wVTLkzbAr_v1yldrWGdquhCZspRoHv0zIHmqnAb_lqH6ypVhM9W3iSpxjVQBQOEdBQwnGYuSP0y_svBQ0c15725GNrZPf4PYTRuyMmXA2LDdusT8m-ihmBmKSM-kuoqOKnSV8AcG4-jaXVANEwTHIABb0pvC880C_pA_LmLu_qpFNBtxDjIJ70DQOw0cNaSnx7s0PyajXQFNCGCZAxzT5aXxI6is97Gg_74bJEQrvOmSqsfFiAGbm8W6jjiOb-6HxrSxnBuvDS35Ha3TsYfuRtp2lR74JNd4UrrA9Svza-5J3Jd-bzZoSIBaO8hoyCEsuC2BirMkfwWZYGuwD7Uc01adYIzV2Bs_9xvrbbcf23Wm2TqLzr6qWzypLS6Wu3qgo_Juud1mipSrkDjJTADBQyqh3OWt7uzOPzif8_AumAkeHwgF-OEJeFp7i1pfQRM5Lizb3DTmjUmNv8P0hc9rjSy_dJxyO-q2_CAbIsWEZ9WwahZHolHG8L6lRVZaWZUF3x_wNvCz1dBH5EiZdy1KDvfRiUGe8cpLZUxMvbg1dT1HHw4d_3-XqyqSUNC8FZzf4fAWqdEc-Q-Qnl4sV4bC_uR3ZdAEq2fXwnJnZN1LPeML78pqo0LtpeKFEOHcoYr-uE1xI6ygs4DWaK-l6yTYep_FfNtCFO9JBMJGy2xjC1PL2fE1UeYehJz9jHW3MDLaGwcsXqWO6gJX-Siq6Z9gfxwCgMAFKCZWbWrL38fw3sMc9eq0Adje5Tw00Wtsn2zaQdHCLbyQSVhu-ao7HzivY4hecCvz10mueRealmle17Et3ZKQGCdtdSBMSbobx0vzypK6stiOvDAsTJIfHE2vMHN3_viP6TAybe0rcFtlN_rJLbJUOOSjCvvMuAbj90NhfMPiK9m9arQsC-7G8rGOoc-WCA88HJ5uqs2vHJD1cEm3Q3ZrultdkfCvQl6XjLbr3KtKyn7ZH9K5VFoh8MYD9SZX8Scidio0rkmigLYMDcuFboSUfxWgHpVQp33q_qvwTdqn5rEw3ogn_sqK8Ir0PC68CvmgoQRvr7TDD2Ygv4miWOfXhkuDkrWaTQHX-3DySHuGBgTs3_ZK7zg21qLQsLs9RCctg-c_6LBEQujLpcgWD5Onteg_f-r2tkjodTe1rVd5dJRYNU8RcCb4ReD5mfVwrHOvbIx8xDxf6vSXSr3yBk7EyYii0WA4JZ_SjkhTzVrQzUQj_WiVNfpNUgh9rin3Ixp7B37Z-7tmfeV-sRs2tGqqwRA_dCLk-H5L01IFqXlQXso6GiVy3DtiAYYTDGzw9Z2M35U4W4pM2S_1zZuyE79Uulx8LYnNNY4WnjWR2czgFzfcbCDFFXU.xRyIGL8Us1LdwmzddcngyYgQDWbO2zrxtSgPgq3fVH0');

                final text = await SecureStorage()
                    .read(SecureStorage.bakaRefreshTokenKey);
                print(text);
              },
              child: const Text('write and read'),
            ),
            FilledButton(
              onPressed: () async {
                final text = await SecureStorage()
                    .read(SecureStorage.bakaRefreshTokenKey);
                print(text);
              },
              child: const Text('only read'),
            ),
            const Divider(),
            const Text('FIREBASE'),
            FilledButton(
              onPressed: () async {
                late List<HomeworkWithID>? fireHws;
                try {
                  fireHws = await firebaseService.getAllHomeworks();
                } catch (e) {
                  if (context.mounted) {
                    showMessage(context, e.toString(), isError: true);
                  }
                }
                if (context.mounted) {
                  showDialogAdaptive(
                      context: context,
                      content: SingleChildScrollView(
                        child: Text(fireHws.toString()),
                      ),
                      actions: [
                        adaptiveDialogButton(
                          context: context,
                          child: const Text('Close'),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        )
                      ]);
                }
              },
              child: const Text('test firebase'),
            ),
            FilledButton(
              onPressed: () async {
                firebaseService.logOut();
              },
              child: const Text('logout from firebase'),
            ),
            const Text('SUBJECTS'),
            const Divider(),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: subjects.entries.map((entry) {
                var item = entry.value;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: 50,
                        child: Text(entry.key.toString()),
                      ),
                      SizedBox(
                        width: 60,
                        child: Text(item.shortcut),
                      ),
                      Expanded(child: Text(item.name)),
                      if (item.isDeleted) const Icon(Icons.delete)
                    ],
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 50),
            const Text('HOMEWORKS'),
            const Divider(),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: hws.entries.map((entry) {
                var item = entry.value;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 50,
                        child: Text(entry.key.toString()),
                      ),
                      SizedBox(
                        width: 30,
                        child: Text(
                          item.priority.toString(),
                          style: TextStyle(
                            color: TaskPriority(item.priority).color,
                          ),
                        ),
                      ),
                      Expanded(child: Text(item.text)),
                      if (item.isCompleted) const Icon(Icons.check),
                      if (entry.value.isDeleted) const Icon(Icons.delete),
                    ],
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 50),
            const Text('EXAMS'),
            const Divider(),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: exams.entries.map((entry) {
                var item = entry.value;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: 50,
                        child: Text(entry.key.toString()),
                      ),
                      SizedBox(
                        width: 30,
                        child: Text(
                          item.priority.toString(),
                          style: TextStyle(
                            color: TaskPriority(item.priority).color,
                          ),
                        ),
                      ),
                      Expanded(child: Text(item.text)),
                      if (entry.value.isDeleted) const Icon(Icons.delete),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
