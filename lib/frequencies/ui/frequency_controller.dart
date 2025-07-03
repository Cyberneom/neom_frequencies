import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:neom_commons/commons/utils/constants/app_page_id_constants.dart';
import 'package:neom_core/core/app_config.dart';
import 'package:neom_core/core/data/implementations/app_drawer_controller.dart';
import 'package:neom_core/core/data/implementations/user_controller.dart';
import 'package:neom_core/core/domain/model/app_profile.dart';
import 'package:neom_core/core/domain/model/neom/neom_frequency.dart';
import 'package:neom_core/core/utils/constants/data_assets.dart';
import '../data/firestore/frequency_firestore.dart';

import '../domain/use_cases/frequency_service.dart';

class FrequencyController extends GetxController implements FrequencyService {

  
  final userController = Get.find<UserController>();

  final RxMap<String, NeomFrequency> frequencies = <String, NeomFrequency>{}.obs;
  final RxMap<String, NeomFrequency> favFrequencies = <String,NeomFrequency>{}.obs;
  final RxMap<String, NeomFrequency> sortedFrequencies = <String,NeomFrequency>{}.obs;  

  final RxBool isLoading = true.obs;  

  AppProfile profile = AppProfile();

  @override
  void onInit() async {
    super.onInit();
    AppConfig.logger.d("Frequencies Init");

    profile = userController.profile;

    try {
      await loadFrequencies();

      if(userController.profile.frequencies != null) {
        favFrequencies.value = userController.profile.frequencies!;
      }

      sortFavFrequencies();
    } catch (e) {
      AppConfig.logger.e(e.toString());
    }

  }

  @override
  Future<void> loadFrequencies() async {
    AppConfig.logger.d("");

    profile.frequencies = await FrequencyFirestore().retrieveFrequencies(profile.id);
    String frequencyStr = await rootBundle.loadString(DataAssets.frequenciesJsonPath);
    List<dynamic> frequencyJSON = jsonDecode(frequencyStr);

    for (var freqJSON in frequencyJSON) {
      NeomFrequency freq = NeomFrequency.fromAssetJSON(freqJSON);
      frequencies[freq.id] = freq;
    }

    AppConfig.logger.d("${frequencies.length} loaded frequencies from json");

    isLoading.value = false;
    update([AppPageIdConstants.frequencies]);
  }

  @override
  Future<void>  addFrequency(int index) async {
    AppConfig.logger.d("");

    NeomFrequency frequency = sortedFrequencies.values.elementAt(index);
    sortedFrequencies[frequency.id]!.isFav = true;

    AppConfig.logger.i("Adding frequency ${frequency.name}");
    if(await FrequencyFirestore().addFrequency(profileId: profile.id, frequency:  frequency)){
      favFrequencies[frequency.id] = frequency;
    }

    sortFavFrequencies();
    update([AppPageIdConstants.frequencies]);
  }

  @override
  Future<void> removeFrequency(int index) async {
    AppConfig.logger.d("Removing Instrument");
    NeomFrequency frequency = sortedFrequencies.values.elementAt(index);

    sortedFrequencies[frequency.id]!.isFav = false;
    AppConfig.logger.d("Removing frequency ${frequency.name}");

    if(await FrequencyFirestore().removeFrequency(profileId: profile.id, frequencyId: frequency.id)){
      favFrequencies.remove(frequency.id);
    }

    sortFavFrequencies();
    update([AppPageIdConstants.frequencies]);
  }

  @override
  void makeMainFrequency(NeomFrequency frequency){
    AppConfig.logger.d("Main frequency ${frequency.name}");

    String prevInstrId = "";
    for (var instr in favFrequencies.values) {
      if(instr.isMain) {
        instr.isMain = false;
        prevInstrId = instr.id;
      }
    }
    frequency.isMain = true;
    favFrequencies.update(frequency.name, (frequency) => frequency);
    FrequencyFirestore().updateMainFrequency(profileId: profile.id,
      frequencyId: frequency.id, prevInstrId:  prevInstrId);

    profile.frequencies![frequency.id] = frequency;
    Get.find<AppDrawerController>().updateProfile(profile);
    update([AppPageIdConstants.frequencies]);

  }

  @override
  void sortFavFrequencies(){

    sortedFrequencies.value = {};

    for (var frequency in frequencies.values) {
      if (favFrequencies.containsKey(frequency.id)) {
        sortedFrequencies[frequency.id] = favFrequencies[frequency.id]!;
      }
    }

    for (var frequency in frequencies.values) {
      if (!favFrequencies.containsKey(frequency.id)) {
        sortedFrequencies[frequency.id] = frequencies[frequency.id]!;
      }
    }

  }

}
