import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:todoapp/modules/blocs/todo_list_bloc.dart';
import 'package:todoapp/modules/pages/home_page.dart';
import 'package:todoapp/modules/pages/statistics_page.dart';
import 'package:todoapp/modules/pages/to_do_detail.dart';
import 'package:todoapp/modules/repository/todo_app_service.dart';

void main() {
  runApp(const MyApp());
}

final GoRouter _router = GoRouter(
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) {
        return const HomePage();
      },
      routes: <RouteBase>[
        GoRoute(
          path: 'todos/:to_do_id',
          builder: (BuildContext context, GoRouterState state) {
            final String todoId = state.pathParameters['to_do_id']!;
            return TodoDetailPage(todoId: todoId);
          },
        ),
      ],
    ),
    GoRoute(
      path: '/statistics',
      builder: (BuildContext context, GoRouterState state) {
        return const StatisticsPage();
      }
    ),
  ],
);


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TodoListBloc(TodoApiService()),
      child: MaterialApp.router(
        title: 'Simple To-Do App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        debugShowCheckedModeBanner: false,
        routerConfig: _router,
      ),
    );
  }
}