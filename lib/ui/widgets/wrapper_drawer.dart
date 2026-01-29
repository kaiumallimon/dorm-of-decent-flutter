import 'package:dorm_of_decents/configs/assets.dart';
import 'package:dorm_of_decents/ui/pages/dashboard_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class WrapperDrawer extends StatelessWidget {
  WrapperDrawer({super.key});

  final List<Map<String, dynamic>> navigationOptions = [
    {
      "icon": Icons.attach_money_rounded,
      "label": "Settlements",
      "path": "/dashboard/settlements",
    },
    {
      "icon": Icons.question_mark,
      "label": "Bills Due",
      "path": "/dashboard/bill_dues",
    },
    {
      "icon": Icons.calendar_month,
      "label": "Months",
      "path": "/dashboard/months",
    },
    {
      "icon": Icons.file_copy,
      "label": "Reports",
      "path": "/dashboard/reports",
    },{
      "icon": Icons.person_2,
      "label": "Users",
      "path": "/dashboard/users",
    },{
      "icon": Icons.history,
      "label": "Activity logs",
      "path": "/dashboard/logs",
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final windowSize = MediaQuery.sizeOf(context);
    return Drawer(
      backgroundColor: theme.scaffoldBackgroundColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _drawerHeader(windowSize, theme),

          const SizedBox(height: 10,),

          Padding(
            padding: const EdgeInsets.only(left: 15, top: 15),
            child: Text('QUICK ACTIONS',style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.onSurface.withAlpha(75)
            ),),
          ),

          // side navigation menus
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(
                vertical: 10
              ),
              itemCount: navigationOptions.length,
              itemBuilder: (context,index){
                final currentItem = navigationOptions[index];

                return ListTile(
                  onTap: (){
                    wrapperScaffoldKey.currentState?.closeDrawer();
                    context.push(currentItem['path']);
                  },
                  leading: Icon(currentItem['icon']),
                  title: Text(currentItem['label']),
                  trailing: Icon(Icons.arrow_forward_ios_outlined,size: 17,color: theme.colorScheme.onSurface.withAlpha(50),),
                );
              })
          ),

          Container(
            margin: EdgeInsets.only(top: 20,bottom: 30, left: 10,right: 10),
            child: ListTile(
              onTap: (){},
              shape: RoundedRectangleBorder(
                side: BorderSide.none,
                borderRadius: BorderRadiusGeometry.circular(10)
              ),
              tileColor: theme.colorScheme.error,
              textColor: theme.colorScheme.onError,
              iconColor: theme.colorScheme.onError,
              trailing: Icon(Icons.logout),
              title: Text('Log out'),
            ),
          )
        ],
      ),
    );
  }

Widget _drawerHeader(Size windowSize, ThemeData theme) {
  return SizedBox(
    height: windowSize.height * 0.32, // 👈 important
    child: Stack(
      children: [
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary,
            border: Border(
              bottom: BorderSide(
                color: theme.colorScheme.onSurface.withAlpha(25),
              ),
            ),
          ),
          padding: EdgeInsets.only(
            top: windowSize.height * 0.10,
            bottom: windowSize.height * 0.065,
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  AppAssets.appLogo,
                  width: windowSize.width * 0.15,
                  height: windowSize.width * 0.15,
                ),
                const SizedBox(height: 20),
                Text(
                  'Dorm of Decents',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontFamily: 'Crimson Text',
                    color: theme.colorScheme.onPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),

        Positioned(
          top: 50,
          right: 10,
          child: IconButton(
            onPressed: () {
              wrapperScaffoldKey.currentState?.closeDrawer();
            },
            icon: Icon(
              Icons.close,
              color: theme.colorScheme.onError,
            ),
          ),
        ),
      ],
    ),
  );
}
}
