import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:neom_commons/app_flavour.dart';
import 'package:neom_commons/ui/theme/app_color.dart';
import 'package:neom_commons/ui/theme/app_theme.dart';
import 'package:neom_commons/ui/widgets/appbar_child.dart';
import 'package:neom_commons/utils/constants/app_page_id_constants.dart';
import 'package:neom_commons/utils/constants/app_translation_constants.dart';
import 'package:neom_core/utils/constants/app_route_constants.dart';

import 'frequency_controller.dart';
import 'widgets/frequency_widgets.dart';

class RootFrequenciesPage extends StatelessWidget {
  const RootFrequenciesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<FrequencyController>(
      id: AppPageIdConstants.frequencies,
      init: FrequencyController(),
      builder: (_) => Scaffold(
        backgroundColor: AppColor.getMain(),
        appBar: AppBarChild(title: AppTranslationConstants.rootFrequencies.tr),
        body: _.isLoading.value ? const Center(child: CircularProgressIndicator())
            : Container(
          decoration: AppTheme.appBoxDecoration,
          child: Column(
              children: <Widget>[
                Expanded(
                  child: buildFreqFavList(context, _),
                ),
              ]
          ),
        ),
        floatingActionButton: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            SizedBox(
              child: DefaultTextStyle(
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
                child: AnimatedTextKit(
                  repeatForever: true,
                  animatedTexts: [
                    FlickerAnimatedText("${AppTranslationConstants.exploreFrequencies.tr}  "),
                  ],
                  onTap: () => {Get.toNamed(AppRouteConstants.frequency)},
                ),
              ),
            ),
            FloatingActionButton(
              heroTag: AppPageIdConstants.spotifySync,
              elevation: AppTheme.elevationFAB,
              child: Row(mainAxisAlignment:MainAxisAlignment.center,children: [Icon(AppFlavour.getAppItemIcon()), const Icon(Icons.navigate_next,size: 20,)],),
              onPressed: () => {Get.toNamed(AppRouteConstants.frequency)},
            ),
          ],
        )
      ),
    );
  }
}
