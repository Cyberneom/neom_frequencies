import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:neom_core/core/app_config.dart';
import 'package:neom_core/core/data/firestore/constants/app_firestore_collection_constants.dart';
import 'package:neom_core/core/data/firestore/constants/app_firestore_constants.dart';
import 'package:neom_core/core/domain/model/neom/neom_frequency.dart';

import '../../domain/repository/frequency_repository.dart';

class FrequencyFirestore implements FrequencyRepository {
  
  final profileReference = FirebaseFirestore.instance.collectionGroup(AppFirestoreCollectionConstants.profiles);


  @override
  Future<Map<String,NeomFrequency>> retrieveFrequencies(profileId) async {
    AppConfig.logger.d("Retrieving NeomFrequency by Profile $profileId");

    Map<String, NeomFrequency> frequencies = {};

    try {
      QuerySnapshot querySnapshot = await profileReference.get();
      for (var document in querySnapshot.docs) {
        if(document.id == profileId) {
          QuerySnapshot qSnapshot = await document.reference
              .collection(AppFirestoreCollectionConstants.frequencies).get();

          for (var queryDocumentSnapshot in qSnapshot.docs) {
            NeomFrequency freq = NeomFrequency.fromJSON(queryDocumentSnapshot.data());
            frequencies[freq.id] = freq;
          }
        }
      }
    } catch (e) {
      AppConfig.logger.e("No frequencies found");
    }

    AppConfig.logger.d("${frequencies.length} frequencies found");
    return frequencies;
  }

  @override
  Future<bool> removeFrequency({required String profileId, required String frequencyId}) async {
    AppConfig.logger.d("Removing $frequencyId for by $profileId");
    try {
      await profileReference.get()
          .then((querySnapshot) async {
        for (var document in querySnapshot.docs) {
          if (document.id == profileId) {
            await document.reference
                .collection(AppFirestoreCollectionConstants.frequencies)
                .doc(frequencyId)
                .delete();
          }
        }
      });

    AppConfig.logger.d("NeomFrequency $frequencyId removed");
    return true;
    } catch (e) {
      AppConfig.logger.e(e.toString());
      return false;
    }
  }

  @override
  Future<bool> addFrequency({required String profileId, required NeomFrequency frequency}) async {
    AppConfig.logger.d("Adding ${frequency.name} for by $profileId");

    try {
      await profileReference.get()
          .then((querySnapshot) async {
        for (var document in querySnapshot.docs) {
          if (document.id == profileId) {
            await document.reference
                .collection(AppFirestoreCollectionConstants.frequencies)
                .doc(frequency.id)
                .set(frequency.toJSON());
          }
        }
      });

      AppConfig.logger.d("NeomFrequency ${frequency.id} added");
      return true;
    } catch (e) {
      AppConfig.logger.e(e.toString());
      return false;
    }
  }

  @override
  Future<bool> updateMainFrequency({required String profileId,
      required String frequencyId, required String prevInstrId}) async {

    AppConfig.logger.d("Updating $frequencyId as main for $profileId");

    try {
      await profileReference.get()
          .then((querySnapshot) async {
        for (var document in querySnapshot.docs) {
          if (document.id == profileId) {
            AppConfig.logger.i("NeomFrequency $frequencyId as main frequency at frequencies collection");
            await document.reference
                .collection(AppFirestoreCollectionConstants.frequencies)
                .doc(frequencyId)
                .update({AppFirestoreConstants.isMain: true});

            AppConfig.logger.d("NeomFrequency $frequencyId as main frequency at profile level");

            await document.reference.update({
              AppFirestoreConstants.mainFrequency: frequencyId
            });

            if(prevInstrId.isNotEmpty) {
              AppConfig.logger.d("NeomFrequency $prevInstrId unset from main frequency");
              await document.reference
                  .collection(AppFirestoreCollectionConstants.frequencies)
                  .doc(prevInstrId)
                  .update({AppFirestoreConstants.isMain: false});
            }
          }
        }
      });

      return true;
    } catch (e) {
      AppConfig.logger.e(e.toString());
      return false;
    }
  }
}
