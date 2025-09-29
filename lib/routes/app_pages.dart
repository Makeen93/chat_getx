import 'package:chat_getx/controllers/chat_controller.dart';
import 'package:chat_getx/controllers/forget_password_controller.dart';
import 'package:chat_getx/controllers/friend_requests_controller.dart';
import 'package:chat_getx/controllers/friends_controller.dart';
import 'package:chat_getx/controllers/notification_controller.dart';
import 'package:chat_getx/routes/app_routes.dart';
import 'package:chat_getx/views/chat_view.dart';
import 'package:chat_getx/views/find_people_view.dart';
import 'package:chat_getx/views/friend_request_view.dart';
import 'package:chat_getx/views/friends_view.dart';
import 'package:chat_getx/views/home_view.dart';
import 'package:chat_getx/views/notification_view.dart';
import 'package:get/get.dart';
import 'package:get/get_navigation/get_navigation.dart';

import '../controllers/change_password_controller.dart';
import '../controllers/home_controller.dart';
import '../controllers/main_controller.dart';
import '../controllers/profile_controller.dart';
import '../controllers/users_list_controller.dart';
import '../views/auth/forget_password_view.dart';
import '../views/auth/login_view.dart';
import '../views/auth/register_view.dart';
import '../views/main_view.dart';
import '../views/profile/change_password_view.dart';
import '../views/profile/profile_view.dart';
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
      binding: BindingsBuilder(() {
        Get.put<ForgetPasswordController>(ForgetPasswordController());
      }),
    ),
    GetPage(
      name: AppRoutes.changePassword,
      page: () => const ChangePasswordView(),
      binding: BindingsBuilder(() {
        Get.put<ChangePasswordController>(ChangePasswordController());
      }),
    ),
    GetPage(
      name: AppRoutes.home,
      page: () => const HomeView(),
      binding: BindingsBuilder(() {
        Get.put<HomeController>(HomeController());
      }),
    ),
    GetPage(
      name: AppRoutes.main,
      page: () => const MainView(),
      binding: BindingsBuilder(() {
        Get.put<MainController>(MainController());
      }),
    ),
    GetPage(
      name: AppRoutes.profile,
      page: () => const ProfileView(),
      binding: BindingsBuilder(() {
        Get.put<ProfileController>(ProfileController());
      }),
    ),
    GetPage(
      name: AppRoutes.chat,
      page: () => const ChatView(),
      binding: BindingsBuilder(() {
        Get.put<ChatController>(ChatController());
      }),
    ),
    GetPage(
      name: AppRoutes.usersList,
      page: () => const FindPeopleView(),
      binding: BindingsBuilder(() {
        Get.put<UsersListController>(UsersListController());
      }),
    ),
    GetPage(
      name: AppRoutes.frinds,
      page: () => const FriendsView(),
      binding: BindingsBuilder(() {
        Get.put<FriendsController>(FriendsController());
      }),
    ),
    GetPage(
      name: AppRoutes.frindRequests,
      page: () => const FriendRequestView(),
      binding: BindingsBuilder(() {
        Get.put<FriendRequestsController>(FriendRequestsController());
      }),
    ),
    GetPage(
      name: AppRoutes.notifications,
      page: () => const NotificationView(),
      binding: BindingsBuilder(() {
        Get.put<NotificationController>(NotificationController());
      }),
    ),
  ];
}
