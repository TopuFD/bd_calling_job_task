import 'package:ddddd/view/homepage.dart';
import 'package:get/get_navigation/src/routes/get_route.dart';

class AppRoute {
  static const initialRoute = "/initialRoute";
  static List<GetPage> pages = [
    GetPage(name: initialRoute, page: ()=>  HomeScreen())
  ];
}
