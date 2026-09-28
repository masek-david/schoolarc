import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:m3e_widgets/m3e_widgets.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:schoolarc/features/plus/plus.dart';
import 'package:schoolarc/utils/extensions/context_extension.dart';
import 'package:schoolarc/utils/extensions/datetime_extension.dart';
import 'package:schoolarc/utils/globals.dart';
import 'package:schoolarc/widgets/tiles/error_tile.dart';

class PlusScreen extends ConsumerStatefulWidget {
  const PlusScreen({super.key});

  @override
  ConsumerState<PlusScreen> createState() => _OfferingsScreenState();
}

class _OfferingsScreenState extends ConsumerState<PlusScreen> {
  Future<Offerings> offerings = Purchases.getOfferings();
  int selected = 0;
  bool loading = false;

  @override
  void initState() {
    super.initState();
  }

  Widget buildPackageTile({
    required BuildContext context,
    required String name,
    required String price,
    required String? pricePerWeek,
    required bool selected,
    required void Function() onSelected,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Material(
        borderRadius: .circular(16),
        color: context.col.surfaceContainer,
        child: InkWell(
          borderRadius: .circular(16),
          splashFactory: NewInkSparkle.splashFactory,
          onTap: onSelected,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: 72,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              borderRadius: .circular(16),
              border: Border.all(
                color: selected ? context.col.primary : Colors.transparent,
                width: 2,
              ),
            ),
            child: Row(
              mainAxisAlignment: .spaceBetween,
              children: [
                Column(
                  mainAxisAlignment: .center,
                  crossAxisAlignment: .start,
                  children: [
                    Text(
                      name,
                      style: context.txt.titleMedium,
                    ),
                    if (pricePerWeek != null) Text('$pricePerWeek per week'),
                  ],
                ),
                Text(
                  price,
                  style: context.txt.titleLarge,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasPlus = ref.watch(schoolarcPlusProvider) == true;

    final scheme = ColorScheme.fromSeed(
      dynamicSchemeVariant: .vibrant,
      seedColor: Colors.amber,
      brightness: context.isDark ? .dark : .light,
    );

    return Theme(
      data: Theme.of(
        context,
      ).copyWith(colorScheme: scheme, scaffoldBackgroundColor: scheme.surface),
      child: Builder(
        builder: (context) {
          return Scaffold(
            appBar: AppBar(
              actions: [
                M3EIconButton(
                  onPressed: () =>
                      ref.read(schoolarcPlusProvider.notifier).refresh(),
                  icon: const Icon(Icons.refresh),
                ),
              ],
            ),
            body: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                children: [
                  if (!hasPlus) const SizedBox(height: 32),
                  if (!hasPlus)
                    Text(
                      'Schoolarc Plus',
                      style: context.txt.displaySmall,
                      textAlign: .center,
                    ),
                  if (!hasPlus) const SizedBox(height: 16),
                  if (!hasPlus)
                    Text(
                      'Cloud Synchronization, ${!kIsWeb && Platform.isAndroid ? 'home screen widgets, ' : ''} notifications, amoled mode, access from web browser',
                      style: context.txt.bodyLarge,
                      textAlign: .center,
                    ),
                  if (hasPlus)
                    Text(
                      'Thank you for supporting Schoolarc ❤️',
                      style: context.txt.displaySmall,
                      textAlign: .center,
                    ),
                  if (hasPlus) const SizedBox(height: 16),
                  if (hasPlus)
                    Text(
                      'Your subscription expires on ${ref.read(schoolarcPlusProvider.notifier).expires?.format(context)}',
                      style: context.txt.bodyLarge,
                      textAlign: .center,
                    ),
                  if (loading)
                    const Center(
                      child: SizedBox(
                        height: 100,
                        width: 100,
                        child: M3ELoadingIndicator(),
                      ),
                    ),
                  const Spacer(),
                  if (!hasPlus)
                    FutureBuilder(
                      future: offerings,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == .waiting) {
                          return const Center(
                            child: SizedBox(
                              height: 100,
                              width: 100,
                              child: M3ELoadingIndicator(),
                            ),
                          );
                        }
                        if (snapshot.hasError) {
                          return ErrorTile(error: snapshot.error);
                        }
                        if (!snapshot.hasData) {
                          return const Text('No data found');
                        }

                        final packages =
                            snapshot.data!.current!.availablePackages;

                        return Column(
                          children: [
                            ...List.generate(
                              packages.length,
                              (index) {
                                final product = packages[index].storeProduct;

                                return buildPackageTile(
                                  context: context,
                                  name: product.title,
                                  price: product.priceString,
                                  pricePerWeek: product.pricePerWeekString,
                                  selected: index == selected,
                                  onSelected: () => setState(() {
                                    selected = index;
                                  }),
                                );
                              },
                            ),
                            const SizedBox(height: 16),
                            M3EFilledButton.icon(
                              size: .md,
                              label: Text(
                                'Buy for ${packages[selected].storeProduct.priceString}',
                              ),
                              icon: const Icon(Icons.attach_money_rounded),
                              onPressed: () async {
                                try {
                                  final purchaseParams = PurchaseParams.package(
                                    packages[selected],
                                  );
                                  setState(() {
                                    loading = true;
                                  });
                                  await Purchases.purchase(purchaseParams);
                                } on PlatformException catch (e) {
                                  var errorCode =
                                      PurchasesErrorHelper.getErrorCode(e);
                                  if (!context.mounted) return;
                                  if (errorCode != .purchaseCancelledError) {
                                    showErrorMessage(context, e);
                                  }
                                }
                                if (!context.mounted) return;
                                setState(() {
                                  loading = false;
                                });
                              },
                            ),
                            const SizedBox(height: 16),
                          ],
                        );
                      },
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
