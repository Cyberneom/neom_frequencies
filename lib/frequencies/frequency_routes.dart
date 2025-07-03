import 'package:get/get.dart';

import 'package:neom_core/core/utils/constants/app_route_constants.dart';
import 'ui/frequency_page.dart';
import 'ui/root_frequencies_page.dart';

class FrequencyRoutes {

  static final List<GetPage<dynamic>> routes = [
    GetPage(
      name: AppRouteConstants.frequencyFav,
      page: () => const RootFrequenciesPage(),
      transition: Transition.leftToRight,
    ),
    GetPage(
      name: AppRouteConstants.frequency,
      page: () => const FrequencyPage(),
      transition: Transition.rightToLeft,
    ),
  ];

}
