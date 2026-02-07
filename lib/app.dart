import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'config/routes.dart';
import 'config/theme.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'features/settings/presentation/bloc/theme_bloc.dart';

class FoodBeGoodApp extends StatelessWidget {
  const FoodBeGoodApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MultiBlocProvider(
          providers: [
            BlocProvider(create: (context) => ThemeBloc()),
            BlocProvider(create: (context) => AuthBloc()),
            BlocProvider(create: (context) => DashboardBloc()),
          ],
          child: BlocBuilder<ThemeBloc, ThemeState>(
            builder: (context, state) {
              return MaterialApp.router(
                title: 'FoodBeGood',
                debugShowCheckedModeBanner: false,
                theme: AppTheme.lightTheme,
                darkTheme: AppTheme.darkTheme,
                themeMode: state.isDarkMode ? ThemeMode.dark : ThemeMode.light,
                routerConfig: AppRouter.router,
                localizationsDelegates: const [
                  ...GlobalMaterialLocalizations.delegates,
                ],
                supportedLocales: const [
                  Locale('en', 'US'),
                  Locale('lt', 'LT'),
                ],
              );
            },
          ),
        );
      },
    );
  }
}
