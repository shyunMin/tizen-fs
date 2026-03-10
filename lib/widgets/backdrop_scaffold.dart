import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tizen_fs/providers/backdrop_provider.dart';
import 'package:tizen_fs/styles/app_style.dart';

class BackdropScaffold extends StatefulWidget {
  final Widget child;

  const BackdropScaffold({super.key, required this.child});

  @override
  State<BackdropScaffold> createState() => _BackdropScaffoldState();
}

class _BackdropScaffoldState extends State<BackdropScaffold> {
  late final _width;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_isInitialized) {
      final devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
      final width = MediaQuery.of(context).size.width;
      setState(() {
        _width = (width * devicePixelRatio).round();
        _isInitialized = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background
          SizedBox.expand(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
              ),
            ),
          ),
          // Backdrop
          AnimatedSwitcher(
            duration: $style.times.fast,
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeOutCubic,
            transitionBuilder:
                (child, animation) => ScaleTransition(
                  scale: Tween<double>(
                    begin: 0.95,
                    end: 1.1,
                  ).animate(animation),
                  child: FadeTransition(opacity: animation, child: child),
                ),
            child: Consumer<BackdropProvider>(
              builder: (context, provider, _) {
                if (provider.url.isEmpty) {
                  return Container();
                } else {
                  return AnimatedScale(
                    duration: $style.times.fast,
                    curve: Curves.easeOutCubic,
                    scale: provider.isZoomIn ? 1.1 : 1.0,
                    child: Container(
                      key: ValueKey(provider.url),
                      alignment: Alignment.topRight,
                      child: CinematicScrim(
                        image: Image.asset(
                          'assets/images/${provider.url}',
                          cacheWidth: (_width > 1920) ? 1920 : _width,
                          width: MediaQuery.of(context).size.width.toDouble(),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  );
                }
              },
            ),
          ),
          // Main content
          widget.child,
        ],
      ),
    );
  }
}

class CinematicScrim extends StatelessWidget {
  const CinematicScrim({super.key, required this.image});

  final Widget image;

  @override
  Widget build(BuildContext context) {
    var surfaceColor = Theme.of(context).colorScheme.surface;
    return Stack(
      children: [
        Padding(padding: const EdgeInsets.all(2.0), child: image),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment(0, 0),
              end: Alignment(0, 1),
              // radius: 2,
              colors: [surfaceColor.withAlpha(0), surfaceColor],
              stops: const [0, 0.8],
            ),
          ),
        ),
      ],
    );
  }
}
