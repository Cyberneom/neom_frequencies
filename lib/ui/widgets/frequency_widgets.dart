// ignore_for_file: use_build_context_synchronously

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:neom_commons/utils/app_alerts.dart';
import 'package:neom_commons/utils/constants/app_translation_constants.dart';
import 'package:neom_commons/utils/constants/message_translation_constants.dart';
import 'package:neom_core/domain/model/neom/neom_frequency.dart';
import 'package:neom_core/utils/constants/app_route_constants.dart';
import '../frequency_controller.dart';

Widget buildFreqFavList(BuildContext context, FrequencyController _) {
  return ListView.separated(
    itemCount: _.favFrequencies.length,
    separatorBuilder:  (context, index) => const Divider(),
    itemBuilder: (__, index) {
      NeomFrequency frequency = _.favFrequencies.values.elementAt(index);

      return ListTile(
          title: Text("${AppTranslationConstants.frequency.tr} ${frequency.frequency.toString()} Hz"),
          subtitle: Text(frequency.description, textAlign: TextAlign.justify,),
          trailing: IconButton(
              icon: const Icon(
                  CupertinoIcons.forward
              ),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onPressed: () {
                Get.toNamed(AppRouteConstants.generator,  arguments: [frequency]);
              }),
        onLongPress: () {
          _.makeMainFrequency(frequency);
          AppAlerts.showAlert(context,
              title: AppTranslationConstants.frequencyPreferences.tr,
              message: "${frequency.name.tr} ${AppTranslationConstants.selectedAsMainFrequency.tr}"
          );
        },
        onTap: () => Get.toNamed(AppRouteConstants.generator,  arguments: [frequency]),
      );
    },
  );
}

Widget buildFrequencyList(BuildContext context, FrequencyController _) {
  return ListView.separated(
    itemCount: _.sortedFrequencies.length,
    separatorBuilder:  (context, index) => const Divider(),
    itemBuilder: (__, index) {
      NeomFrequency frequency = _.sortedFrequencies.values.elementAt(index);
      if (_.favFrequencies[frequency.id] != null) {
        frequency = _.favFrequencies[frequency.id]!;
      }
      return ListTile(
          title: Text("${AppTranslationConstants.frequency.tr} ${frequency.frequency.toString()} Hz"),
          subtitle: Text(frequency.description, textAlign: TextAlign.justify),
          trailing: IconButton(
              icon: Icon(
                frequency.isFav ? Icons.remove : Icons.add,
              ),
              onPressed: () async {
                if(frequency.isFav) {
                  if (_.favFrequencies.length > 1) {
                    await _.removeFrequency(index);
                    if(_.favFrequencies.containsKey(frequency.id)) {
                      AppAlerts.showAlert(context,
                          title: "${AppTranslationConstants.frequency.tr} ${frequency.frequency.toString()} Hz",
                          message: MessageTranslationConstants.frequencyNotRemoved.tr
                      );
                    } else {
                      AppAlerts.showAlert(context,
                          title: "${AppTranslationConstants.frequency.tr} ${frequency.frequency.toString()} Hz",
                          message: MessageTranslationConstants.frequencyRemoved.tr
                      );
                    }
                  } else {
                    AppAlerts.showAlert(context,
                        title: "${AppTranslationConstants.frequency.tr} ${frequency.frequency.toString()} Hz",
                        message: MessageTranslationConstants.atLeastOneFrequency.tr
                    );
                  }
                } else {
                  await _.addFrequency(index);
                  if(_.favFrequencies.containsKey(frequency.id)) {
                    AppAlerts.showAlert(context,
                        title: "${AppTranslationConstants.frequency.tr} ${frequency.frequency.toString()} Hz",
                        message: MessageTranslationConstants.frequencyAdded.tr
                    );
                  } else {
                    AppAlerts.showAlert(context,
                        title: "${AppTranslationConstants.frequency.tr} ${frequency.frequency.toString()} Hz",
                        message: MessageTranslationConstants.frequencyNotAdded.tr
                    );
                  }
                }
              }
          ),
          onTap: () => Get.toNamed(AppRouteConstants.generator,  arguments: [frequency]),
      );
    },
  );
}
