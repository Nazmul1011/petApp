import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppScaffold extends StatelessWidget {
  final PreferredSizeWidget? appBar;
  final Widget? body;
  final Widget? drawer;
  final Widget? endDrawer;
  final Widget? bottomNavigationBar;
  final String message;
  final bool? resizeToAvoidBottomInset;
  final bool extendBodyBehindAppBar;
  final bool useSafeArea;
  final double horizontalPadding;
  final double verticalPadding;

  const AppScaffold({
    super.key,
    this.body,
    this.appBar,
    this.drawer,
    this.endDrawer,
    this.bottomNavigationBar,
    this.message = 'Welcome!\nYour Flutter playground awaits... 🎯',
    this.horizontalPadding = 16,
    this.verticalPadding = 0,
    this.resizeToAvoidBottomInset,
    this.extendBodyBehindAppBar = false,
    this.useSafeArea = true,
    this.statusBarIconBrightness = Brightness.dark,
    this.systemNavigationBarIconBrightness = Brightness.dark,
  });

  final Brightness statusBarIconBrightness;
  final Brightness systemNavigationBarIconBrightness;

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        systemNavigationBarColor: Colors.transparent,
        statusBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: systemNavigationBarIconBrightness,
        statusBarIconBrightness: statusBarIconBrightness,
      ),
    );

    return Scaffold(
      extendBodyBehindAppBar: extendBodyBehindAppBar,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      appBar: appBar,
      drawer: drawer,
      endDrawer: endDrawer,
      bottomNavigationBar: bottomNavigationBar,
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    final bodyContent = Padding(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: verticalPadding,
      ),
      child:
          body ??
          Center(
            child: Text(
              message,
              style: const TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
          ),
    );

    if (useSafeArea) {
      return SafeArea(child: bodyContent);
    }
    return bodyContent;
  }
}
