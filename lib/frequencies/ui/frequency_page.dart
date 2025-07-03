import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:neom_commons/commons/ui/theme/app_theme.dart';
import 'package:neom_commons/commons/ui/widgets/appbar_child.dart';
import 'package:neom_commons/commons/utils/constants/app_page_id_constants.dart';
import 'package:neom_commons/commons/utils/constants/app_translation_constants.dart';
import 'frequency_controller.dart';
import 'widgets/frequency_widgets.dart';

class FrequencyPage extends StatelessWidget {
  const FrequencyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<FrequencyController>(
      id: AppPageIdConstants.frequencies,
      init: FrequencyController(),
      builder: (_) => Scaffold(
        appBar:  PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: AppBarChild(title: AppTranslationConstants.frequencySelection.tr)),
        body: Container(
          decoration: AppTheme.appBoxDecoration,
          child: Column(
              children: <Widget>[
                Obx(()=> Expanded(
                  child: buildFrequencyList(context, _),
                ),),
              ]
          ),
        ),
      ),
    );
  }

}
