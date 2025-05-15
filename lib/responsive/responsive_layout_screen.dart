//better make this way to make it responsive

import 'package:flutter/material.dart';
import 'package:utmhub/utils/dimensions.dart';
class ResponsiveLayout extends StatelessWidget{
  final Widget webScreenlayout;
  final Widget mobileScreenLayout;
//we want to return a webscreen so we gonna call a widget
  const ResponsiveLayout({Key? key, required this.webScreenlayout, required this.mobileScreenLayout}):super(key:key);


  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints){
        //using constraints as it will give us more methods to work with
        if (constraints.maxWidth > webScreenSize)//resolved: a bit unsure about the logic here, should be the other way around but it seems to have some issue
        {
          //will show website layout
          return webScreenlayout;
        }
        //mobile screen layout otherwise
        return mobileScreenLayout;


      },
    );
    // TODO: implement build
    //throw UnimplementedError();
  }
} 