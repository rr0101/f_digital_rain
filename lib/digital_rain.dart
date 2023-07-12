import 'dart:math';
import 'package:flutter/material.dart';

// my first implementation
class DigitalRain extends StatefulWidget {
  const DigitalRain({Key? key}) : super(key: key);

  @override
  State<DigitalRain> createState() => _DigitalRainState();
}

class _DigitalRainState extends State<DigitalRain>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  List<Raindrop> _raindrops = [];

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();

    _controller.addListener(() {
      setState(() {
        _raindrops = updateRaindrops();
      });
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_raindrops.isEmpty) {}
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void resetAnimation() {
    _controller.reset();
  }

  List<Raindrop> updateRaindrops() {
    List<Raindrop> list = [];
    for (int i = 0; i < _raindrops.length; i++) {
      if (_raindrops[i].dropHead > 200) {
        _raindrops.removeAt(i);
      }
    }
    if (_raindrops.length < 70) {
      _initializeRaindrops(40);
    }
    for (int i = 0; i < _raindrops.length; i++) {
      list.add(Raindrop(
          dropHead: _raindrops[i].dropHead + 1,
          dropLength: _raindrops[i].dropLength,
          offsetX: _raindrops[i].offsetX,
          offsetY: _raindrops[i].offsetY,
          speed: _raindrops[i].speed,
          randomRainChars: _raindrops[i].randomRainChars,
          fontSize: _raindrops[i].fontSize));
    }
    return list;
  }

  void _initializeRaindrops(numberOfDrops) {
    for (var i = 0; i < numberOfDrops; i++) {
      final random = Random();
      final double speed = 0.005 + (1.8 * random.nextDouble());
      // Chars
      const String charBase =
          'ﾊﾐﾋｰｳｼﾅﾓﾆｻﾜﾂｵﾘｱﾎﾃﾏｹﾒｴｶｷﾑﾕﾗｾﾈｽﾀﾇﾍﾊﾐﾋｰｳｼﾅﾓﾆｻﾜﾂｵﾘｱﾎﾃﾏｹﾒｴｶｷﾑﾕﾗｾﾈｽﾀﾇﾍ1234567890+-*%<>.,:;';
      // final List<String> randomRainChars = [];
      const double fontSize = 21;
      final currentWindowSize =
          MediaQueryData.fromWindow(WidgetsBinding.instance.window).size;
      //Window-Size
      final double windowWidth = currentWindowSize.width;
      final double windowHeight = currentWindowSize.height;

      final int windowMaxVerticalChars = windowHeight ~/ fontSize + 50;
      //highlighting
      final int dropHead = -1 * (random.nextInt(50) + 1);
      final int dropLength = random.nextInt(200) + 3;
      final int offsetX =
          (windowWidth / 2 - (windowWidth) * random.nextDouble()).toInt();
      const double offsetY = -20;

      List<String> buildCharsForTextSpans(int windowMaxVerticalChars) {
        String randomChar() {
          final index = Random().nextInt(charBase.length);
          return "  ${charBase.substring(index, index + 1)}  \n";
        }

        return List.generate(windowMaxVerticalChars, (index) {
          String char = randomChar();
          return char;
        });
      }

      //Stringbuilder
      List<String> randomRainChars =
          buildCharsForTextSpans(windowMaxVerticalChars);

      _raindrops.add(Raindrop(
        dropHead: dropHead,
        dropLength: dropLength,
        offsetX: offsetX,
        offsetY: offsetY,
        speed: speed,
        randomRainChars: randomRainChars,
        fontSize: fontSize,
      ));
    }
  }

// Stacking Raindrops
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      _raindrops.removeWhere((raindrop) => raindrop.disposed == true);

      return Stack(
        children: _raindrops,
      );
    });
  }
}

class Raindrop extends StatelessWidget {
  const Raindrop(
      {super.key,
      required this.dropHead,
      required this.dropLength,
      required this.offsetX,
      required this.offsetY,
      required this.speed,
      required this.randomRainChars,
      required this.fontSize});
  final int dropHead;
  final int dropLength;
  // Fontsize
  final double fontSize;
  // Offset
  final int offsetX;
  final double offsetY;
  // Speed
  final double speed;
  // Chars
  final List<String> randomRainChars;
  final bool disposed = false;

  // build TextSpans for Rain Column
  List<TextSpan> buildTextSpans(List<String> chars, int dropHead, double speed,
      int dropLength, int windowMaxVerticalChars) {
    final int activeDropHead = dropHead * speed.toInt();
    final int dropEnd = activeDropHead - dropLength;
    return List.generate(chars.length, (index) {
      Color color;
      Shadow glow;

      if (index == dropEnd - 3) {
        color = const Color.fromARGB(255, 21, 53, 23).withOpacity(0.3);
        glow = const Shadow(
          color: Colors.black,
          blurRadius: 0,
        );
      } else if (index == dropEnd - 2) {
        color = const Color.fromARGB(255, 29, 72, 31).withOpacity(0.7);
        glow = const Shadow(
          color: Colors.black,
          blurRadius: 0,
        );
      } else if (index == dropEnd - 1) {
        color = const Color.fromARGB(255, 44, 109, 48);
        glow = const Shadow(
          color: Colors.black,
          blurRadius: 0,
        );
      } else if (index >= dropEnd && index < activeDropHead - 1) {
        color = Color.fromARGB(255, 29, 203, 14);
        glow = const Shadow(
            color: Color.fromARGB(255, 255, 255, 255),
            blurRadius: 0,
            offset: Offset(0, 0));
      } else if (index == activeDropHead - 1) {
        color = Color.fromARGB(255, 192, 255, 199);
        glow = const Shadow(
            color: Color.fromARGB(255, 255, 255, 255),
            blurRadius: 3,
            offset: Offset(0, 0));
      } else if (index == activeDropHead) {
        color = Colors.white;
        glow = const Shadow(
            color: Colors.white, blurRadius: 8, offset: Offset(0, 0));
      } else {
        color = Colors.black.withOpacity(0);
        glow = const Shadow(
          color: Colors.black,
          blurRadius: 0,
        );
      }

      // add a custom colored TextSpan to the List of TextSpans that make one Column
      return TextSpan(
          text: chars[index],
          style: TextStyle(
              fontFamily: "rocknRollOne",
              fontSize: fontSize,
              color: color,
              shadows: [glow], //!= null ? [glow] : null,
              height: 0.9));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: Transform.translate(
        offset: Offset(offsetX.toDouble(), offsetY),
        child: RichText(
          text: TextSpan(
            children: buildTextSpans(randomRainChars, dropHead, speed,
                dropLength, randomRainChars.length),
          ),
        ),
      ),
    );
  }
}
