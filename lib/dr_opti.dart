import 'dart:math';
import 'package:flutter/material.dart';

// I tried to optimize the animation here
class DROpti extends StatefulWidget {
  const DROpti({super.key});

  @override
  State<DROpti> createState() => _DROptiState();
}

class _DROptiState extends State<DROpti> with TickerProviderStateMixin {
  late AnimationController _controller;
  List<Raindrop> raindrops = [];
  final size = MediaQueryData.fromView(WidgetsBinding.instance.window).size;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();

    _controller.addListener(() {
      setState(() {
        for (int i = 0; i < raindrops.length; i++) {
          if (raindrops[i].dropHead - raindrops[i].dropLength >
              size.height / raindrops[i].fontSize + 30) {
            raindrops.removeAt(i);
          }
        }

        if (raindrops.length < (size.width)) {
          raindrops = ManageRaindrops().addRaindrops(1, raindrops);
        }
        raindrops = ManageRaindrops().fall(raindrops);
      });
    });
  }

// to make it faster, tried painting in TextPainter
  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      color: Colors.black,
      duration: const Duration(seconds: 5),
      child: Stack(
        children: [
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return CustomPaint(
                painter: RaindropPainter(ManageRaindrops().fall(raindrops)),
              );
            },
          )
        ],
      ),
    );
  }
}

class RaindropPainter extends CustomPainter {
  final List<Raindrop> raindrops;

  RaindropPainter(this.raindrops);

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < raindrops.length; i++) {
      final raindrop = raindrops[i];

      final textPainter = TextPainter(
        text: raindrop.textSpans(),
        textDirection: TextDirection.ltr,
      );

      textPainter.layout(minWidth: 0, maxWidth: size.width);

      final offset = Offset(raindrop.offsetX.toDouble(), raindrop.offsetY);

      textPainter.paint(canvas, offset);
    }
  }

  @override
  bool shouldRepaint(RaindropPainter oldDelegate) => true;
}

class ManageRaindrops {
  // Takes List of Raindrops, adds Raindrops
  List<Raindrop> addRaindrops(numberOfDrops, List<Raindrop> raindrops) {
    List<Raindrop> updatedRaindrops = raindrops;
    for (var i = 0; i < numberOfDrops; i++) {
      final random = Random();
      final double speed = 0.005 + (2.2 * random.nextDouble());
      // Chars used in Animation
      const String charBase =
          'ﾊﾐﾋｰｳｼﾅﾓﾆｻﾜﾂｵﾘｱﾎﾃﾏｹﾒｴｶｷﾑﾕﾗｾﾈｽﾀﾇﾍﾊﾐﾋｰｳｼﾅﾓﾆｻﾜﾂｵﾘｱﾎﾃﾏｹﾒｴｶｷﾑﾕﾗｾﾈｽﾀﾇﾍ1234567890+-*%<>.,:;';
      // final List<String> randomRainChars = [];
      const double fontSize = 21;
      final currentWindowSize =
          MediaQueryData.fromView(WidgetsBinding.instance.window).size;
      // Window-Size
      final double windowWidth = currentWindowSize.width;
      final double windowHeight = currentWindowSize.height;
      final int windowMaxVerticalChars = windowHeight ~/ fontSize + 50;
      // Drop-Head and Length
      final int dropHead = -1 * (random.nextInt(50) + 1);
      final int dropLength = random.nextInt(70) + 3;
      // Drop Positioning
      final double offsetX =
          (windowWidth - (windowWidth) * random.nextDouble());
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

      updatedRaindrops.add(Raindrop(
        dropHead: dropHead,
        dropLength: dropLength,
        offsetX: offsetX,
        offsetY: offsetY,
        speed: speed,
        randomRainChars: randomRainChars,
        fontSize: fontSize,
      ));
    }
    return updatedRaindrops;
  }

// moves all raindrops by  1*(their speed)
  List<Raindrop> fall(List<Raindrop> raindrops) {
    List<Raindrop> updatedRaindrops = [];
    for (int i = 0; i < raindrops.length; i++) {
      updatedRaindrops.add(Raindrop(
          dropHead: raindrops[i].dropHead + 1,
          dropLength: raindrops[i].dropLength,
          offsetX: raindrops[i].offsetX,
          offsetY: raindrops[i].offsetY,
          speed: raindrops[i].speed,
          randomRainChars: raindrops[i].randomRainChars,
          fontSize: raindrops[i].fontSize));
    }
    return updatedRaindrops;
  }
}

class Raindrop {
  Raindrop(
      {required this.dropHead,
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
  final double offsetX;
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
        color = Color.fromARGB(255, 51, 255, 33);
        glow = const Shadow(
          color: Colors.black,
          blurRadius: 8,
          offset: Offset(0, 0),
        );
      } else if (index == activeDropHead - 1) {
        color = const Color.fromARGB(255, 192, 255, 199);
        glow = const Shadow(
            color: Color.fromARGB(255, 255, 255, 255),
            blurRadius: 5,
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

  TextSpan textSpans() {
    return TextSpan(
      children: buildTextSpans(
          randomRainChars, dropHead, speed, dropLength, randomRainChars.length),
    );
  }
}
