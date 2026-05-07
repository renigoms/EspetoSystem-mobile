import 'package:espetosystem/app/UI/authentication/pages/login_page.dart';
import 'package:espetosystem/app/UI/authentication/view_models/auth_view_model.dart';
import 'package:espetosystem/app/UI/authentication/widgets/selection_buttons.dart';
import 'package:espetosystem/app/UI/authentication/widgets/title_container.dart';
import 'package:espetosystem/app/core/colors/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class AuthScreen extends StatelessWidget {
  AuthScreen({super.key});

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    final theme = Theme.of(context);
    final AuthViewModel loginModelView = Provider.of<AuthViewModel>(context);
    final bool isLogin = loginModelView.isLogin;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Flexible(flex: 3, child: TitleContainer(theme: theme)),
            Flexible(
              flex: 5,
              child: Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.secondary,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColorsEnum.blackOpacit25percent.color,
                      blurRadius: 4,
                      offset: Offset(0, -5),
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: Column(
                  spacing: 20,
                  children: [
                    SelectionButtons(isLogin: isLogin, theme: theme),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              transitionBuilder: (
                                Widget child,
                                Animation<double> animation,
                              ) {
                                return FadeTransition(
                                  opacity: animation,
                                  child: child,
                                );
                              },
                              child:
                                  isLogin
                                      ? LoginPage(
                                        theme: theme,
                                        emailController: _emailController,
                                        passwordController: _passwordController,
                                      )
                                      : Text(
                                        key: ValueKey<bool>(isLogin),
                                        "Area de resgistro",
                                        style: theme.textTheme.titleLarge,
                                      ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
