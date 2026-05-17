import 'package:espetosystem/app/UI/home/widgets/app_bar.dart';
import 'package:espetosystem/app/UI/home/widgets/filter_arrow.dart';
import 'package:espetosystem/app/UI/home/widgets/filter_bar_custom.dart';
import 'package:espetosystem/app/UI/home/widgets/search_bar_static_custom.dart';
import 'package:espetosystem/app/UI/home/widgets/user_add_plus_custom.dart';
import 'package:flutter/material.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final orientation = MediaQuery.of(context).orientation;
    final theme = Theme.of(context);
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(75),
        child: AppBarCustom(theme: theme),
      ),

      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              padding: EdgeInsets.only(top: 15),
              child: Column(
                spacing: 25,
                children: [
                  Row(
                    spacing: 17,
                    children: [
                      Expanded(
                        flex: orientation == Orientation.portrait ? 4 : 9,
                        child: SearchBarStaticCustom(theme: theme),
                      ),
                      Flexible(
                        flex: 1,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            UserAddPlusCustom(theme: theme),
                            FilterArrow(theme: theme),
                          ],
                        ),
                      ),
                    ],
                  ),
                  FilterBarCustom(theme: theme),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
