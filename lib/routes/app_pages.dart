import 'package:chat_getx/routes/app_routes.dart';
import 'package:get/get.dart';
import 'package:get/get_navigation/get_navigation.dart';

import '../views/auth/forget_password_view.dart';
import '../views/auth/login_view.dart';
import '../views/auth/register_view.dart';
import '../views/splash_view.dart';

class AppPages {
  static const initial = AppRoutes.splash;

  static final routes = [
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashView(),
      // binding: BindingsBuilder(){
      //   Get.put<SplashController>(SplashController());
      // },
    ),
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginView(),
      // binding: BindingsBuilder(){
      //   Get.put<LoginController>(LoginController());
      // },
    ),
    GetPage(
      name: AppRoutes.register,
      page: () => const RegisterView(),
      // binding: BindingsBuilder(){
      //   Get.put<RegisterController>(RegisterController());
      // },
    ),
    GetPage(
      name: AppRoutes.forgetPassword,
      page: () => const ForgetPasswordView(),
      // binding: BindingsBuilder(){
      //   Get.put<ForgetPasswordController>(ForgetPasswordController());
      // },
    ),
    // GetPage(
    //   name: AppRoutes.changePassword,
    //   page: () => ChangePasswordView(),
    //   binding: BindingsBuilder(){
    //     Get.put<ChangePasswordController>(ChangePasswordController());
    //   },
    // ),
    // GetPage(
    //   name: AppRoutes.home,
    //   page: () => HomeView(),
    //   binding: BindingsBuilder(){
    //     Get.put<HomeController>(HomeController());
    //   },
    // ),
    // GetPage(
    //   name: AppRoutes.main,
    //   page: () => MainView(),
    //   binding: BindingsBuilder(){
    //     Get.put<MainController>(MainController());
    //   },
    // ),
    // GetPage(
    //   name: AppRoutes.profile,
    //   page: () => ProfileView(),
    //   binding: BindingsBuilder(){
    //     Get.put<ProfileController>(ProfileController());
    //   },
    // ),
    // GetPage(
    //   name: AppRoutes.chat,
    //   page: () => ChatView(),
    //   binding: BindingsBuilder(){
    //     Get.put<ChatController>(ChatController());
    //   },
    // ),
    // GetPage(
    //   name: AppRoutes.usersList,
    //   page: () => UsersListView(),
    //   binding: BindingsBuilder(){
    //     Get.put<UsersListController>(UsersListController());
    //   },
    // ),
    // GetPage(
    //   name: AppRoutes.frinds,
    //   page: () => FrindsView(),
    //   binding: BindingsBuilder(){
    //     Get.put<FrindsController>(FrindsController());
    //   },
    // ),
    // GetPage(
    //   name: AppRoutes.frindRequests,
    //   page: () => FrindRequestsView(),
    //   binding: BindingsBuilder(){
    //     Get.put<FrindRequestsController>(FrindRequestsController());
    //   },
    // ),
    // GetPage(
    //   name: AppRoutes.notifications,
    //   page: () => NotificationsView(),
    //   binding: BindingsBuilder(){
    //     Get.put<NotificationsController>(NotificationsController());
    //   },
    // ),
  ];
}
