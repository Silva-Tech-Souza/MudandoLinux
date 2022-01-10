import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_appexemplo/main.dart';

// aqui é como se fosse o antigo painter
class CanvasPathsState extends ChangeNotifier {
  PathHistoryDois pathHistory = PathHistoryDois();
  Color drawColor1 = const Color.fromARGB(255, 0, 0, 0);
  Color backgroundColor1 = const Color.fromARGB(255, 255, 255, 255);
  bool modoBorracha = false;
  double thickness1 = 4.0;
  StrokeCap strokeCapVar = StrokeCap.round;
  StrokeJoin strokeJoinVar = StrokeJoin.round;
  CurrentPathState ctrlCurrent = CurrentPathState();
  BlendMode blendMode = BlendMode.clear;

  CanvasPathsState() {
    pathHistory = PathHistoryDois();
    ctrlCurrent = CurrentPathState();
    notifyListeners();
  }

  Color get backgroundColor => backgroundColor1;
  set backgroundColor(Color color) {
    backgroundColor1 = color;
    updatePaint();
  }

  BlendMode get modeblend => blendMode;
  set modeblend(BlendMode enabled) {
    blendMode = enabled;
    updatePaint();
  }

  bool get eraseMode => modoBorracha;
  set eraseMode(bool enabled) {
    modoBorracha = enabled;
    updatePaint();
  }

  StrokeCap get strokeCapMode => strokeCapVar;
  set strokeCapMode(StrokeCap enabled) {
    strokeCapVar = enabled;
    updatePaint();
  }

  StrokeJoin get strokeJoinMode => strokeJoinVar;
  set strokeJoinMode(StrokeJoin enabled) {
    strokeJoinVar = enabled;
    updatePaint();
  }

  void undo() {
    pathHistory.voltar();
    notifyList();
  }

  void redo() {
    pathHistory.redo();
    notifyList();
  }

  Color get drawColor => drawColor1;
  set drawColor(Color color) {
    drawColor1 = color;
    updatePaint();
  }

  double get thickness => thickness1;
  set thickness(double t) {
    thickness1 = t;
    updatePaint();
  }

  void updatePaint() {
    Paint paint = Paint();
    if (modoBorracha) {
      //paint.blendMode = BlendMode.clear;
      paint.blendMode = blendMode;
      if (pintarFundo) {
        paint.color = drawColor;
      } else {
        paint.color = const Color.fromARGB(255, 255, 255, 255);
      }
      // paint.color = const Color.fromARGB(0, 255, 0, 0);
    } else {
      paint.color = drawColor;
    }
    paint.strokeJoin = strokeJoinVar;
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = thickness;
    paint.strokeCap = strokeCapVar;
    paint.filterQuality = FilterQuality.high;
    paint.isAntiAlias = true;
    pathHistory.setBackgroundColor(backgroundColor);
    pathHistory.currentPaint = paint;
    notifyList();
  }

  notifyList() {
    notifyListeners();
  }
}

class CurrentPathState extends ChangeNotifier {
  PathHistory pathHistory = PathHistory();
  Color _drawColor = const Color.fromARGB(255, 0, 0, 0);
  Color _backgroundColor = const Color.fromARGB(255, 255, 255, 255);
  bool _modoBorracha = false;
  double _thickness = 4.0;
  StrokeCap strokeCapVar = StrokeCap.round;
  StrokeJoin strokeJoinVar = StrokeJoin.round;

  CurrentPathState() {
    pathHistory = PathHistory();

    _backgroundColor = const Color.fromARGB(255, 255, 255, 255);

    thickness = 4.0;
  }

  bool get eraseMode => _modoBorracha;

  set eraseMode(bool enabled) {
    _modoBorracha = enabled;
    updatePaint();
  }

  Color get drawColor => _drawColor;
  set drawColor(Color color) {
    _drawColor = color;
    updatePaint();
  }

  StrokeCap get strokeCapMode => strokeCapVar;
  set strokeCapMode(StrokeCap enabled) {
    strokeCapVar = enabled;
    updatePaint();
  }

  StrokeJoin get strokeJoinMode => strokeJoinVar;
  set strokeJoinMode(StrokeJoin enabled) {
    strokeJoinVar = enabled;
    updatePaint();
  }

  Color get backgroundColor => _backgroundColor;
  set backgroundColor(Color color) {
    _backgroundColor = color;
    updatePaint();
  }

  double get thickness => _thickness;
  set thickness(double t) {
    _thickness = t;
    updatePaint();
  }

  void updatePaint() {
    Paint paint = Paint();
    if (_modoBorracha) {
      //paint.blendMode = BlendMode.clear;
      paint.blendMode = BlendMode.saturation;
      paint.color = const Color.fromARGB(0, 255, 0, 0);
    } else {
      paint.color = pickerColor;
    }
    paint.strokeJoin = strokeJoin;
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = lapizTamanho;
    paint.strokeCap = strokeCap;
    paint.filterQuality = FilterQuality.high;
    paint.isAntiAlias = true;
    pathHistory.setBackgroundColor(backgroundColor);
    pathHistory.currentPaint = paint;
    notifyListeners();
  }

  void notifyList() {
    notifyListeners();
  }
}

class PathHistoryDois {
  List<MapEntry<Path, Paint>> _undone = <MapEntry<Path, Paint>>[];
  List<MapEntry<Path, Paint>> paths = <MapEntry<Path, Paint>>[];
  bool inDrag = false;
  Paint backgroundPaint1 = Paint();
  Paint backgroundPaint2 = Paint();
  Paint currentPaint = Paint();
  Path pathmove = Path();

  Offset previousOffset = const Offset(0, 0);

  PathHistoryDois() {
    paths = <MapEntry<Path, Paint>>[];
    _undone = <MapEntry<Path, Paint>>[];
    inDrag = false;
    backgroundPaint2 = Paint()..blendMode = BlendMode.dstOver;
  }
  Paint get backgroundColor => backgroundPaint2;
  setBackgroundColor(Color backgroundColor) {}

  List<MapEntry<Path, Paint>> get points => paths;

  bool canUndo() => paths.isNotEmpty;
  voltar() {
    if (canUndo()) {
      _undone.add(paths.removeLast());
    }
  }

  bool canRedo() => _undone.isNotEmpty;
  redo() {
    if (canRedo()) {
      paths.add(_undone.removeLast());
    }
  }

  adicionar(Offset startPoint) {
    if (modolapiz) {
      if (!inDrag) {
        inDrag = true;
        pathmove = Path()..moveTo(startPoint.dx, startPoint.dy);
        paths.add(MapEntry<Path, Paint>(pathmove, currentPaint));
      }
    } else {
      if (!retasAtuando) {
        retasAtuando = true;
        inDrag = false;
        pathmove = Path()..moveTo(startPoint.dx, startPoint.dy);
        paths.add(MapEntry<Path, Paint>(pathmove, currentPaint));
      } else {
        paths.last.key.lineTo(startPoint.dx, startPoint.dy);
        pathmove = Path()..moveTo(startPoint.dx, startPoint.dy);
        paths.add(MapEntry<Path, Paint>(pathmove, currentPaint));
      }
    }
  }

  updateCurrent(Offset nextPoint) {
    if (modolapiz) {
      // if (inDrag) {
      if (strokeJoin == StrokeJoin.round) {
        var dx = nextPoint.dx;
        var dy = nextPoint.dy;

        if (previousOffset == const Offset(0, 0)) {
          pathmove.lineTo(dx, dy);
        } else {
          var previousDx = previousOffset.dx;
          var previousDy = previousOffset.dy;

          pathmove.quadraticBezierTo(
            previousDx,
            previousDy,
            (previousDx + dx) / 2,
            (previousDy + dy) / 2,
          );
        }
        previousOffset = nextPoint;
      } else {
        pathmove.lineTo(nextPoint.dx, nextPoint.dy);
      }
      //  }
    }
  }

  resetPoints() {
    if (modolapiz) {
      inDrag = false;
      pathmove = Path();
      previousOffset = const Offset(0, 0);
    }
  }

  limpar() {
    pathmove = Path();
    previousOffset = const Offset(0, 0);
    inDrag = false;
    paths.clear();
  }

  draw(Canvas canvas, Size size) {
    canvas.saveLayer(Offset.zero & size, Paint());

    for (MapEntry<Path, Paint> path in paths) {
      Paint p = path.value;
      canvas.drawPath(path.key, p);
    }

    canvas.restore();
  }

  addPath(pathh) {
    if (modolapiz) {
      for (var path in pathh) {
        paths.add(MapEntry<Path, Paint>(path.key, path.value));
      }
    }
  }
}

class PathHistory {
  List<MapEntry<Path, Paint>> paths = <MapEntry<Path, Paint>>[];
  bool inDrag = false;
  Paint backgroundPaint1 = Paint();
  Paint currentPaint = Paint();
  Path pathmove = Path();
  Offset previousOffset = const Offset(0, 0);

  PathHistory() {
    paths = <MapEntry<Path, Paint>>[];
    inDrag = false;
    modolapiz = true;
    backgroundPaint1 = Paint()..blendMode = BlendMode.dstOver;
  }

  List<MapEntry<Path, Paint>> get points => paths;

  setBackgroundColor(Color backgroundColor) {
    backgroundPaint1.color = backgroundColor;
  }

  adicionar(Offset startPoint) {
    if (modolapiz) {
      if (!inDrag) {
        inDrag = true;
        pathmove = Path()..moveTo(startPoint.dx, startPoint.dy);
        paths.add(MapEntry<Path, Paint>(pathmove, currentPaint));
      }
    } else {
      if (paths.isEmpty) {
        inDrag = false;
        pathmove = Path()..moveTo(startPoint.dx, startPoint.dy);
        paths.add(MapEntry<Path, Paint>(pathmove, currentPaint));
      } else {
        paths.last.key.lineTo(startPoint.dx, startPoint.dy);
        pathmove = Path()..moveTo(startPoint.dx, startPoint.dy);
        paths.add(MapEntry<Path, Paint>(pathmove, currentPaint));
      }
    }
  }

  updateCurrent(Offset nextPoint) {
    if (modolapiz) {
      // if (inDrag) {
      if (strokeJoin == StrokeJoin.round) {
        var dx = nextPoint.dx;
        var dy = nextPoint.dy;

        if (previousOffset == const Offset(0, 0)) {
          pathmove.lineTo(dx, dy);
        } else {
          var previousDx = previousOffset.dx;
          var previousDy = previousOffset.dy;

          pathmove.quadraticBezierTo(
            previousDx,
            previousDy,
            (previousDx + dx) / 2,
            (previousDy + dy) / 2,
          );
        }
        previousOffset = nextPoint;
      } else {
        pathmove.lineTo(nextPoint.dx, nextPoint.dy);
      }
      //}
    }
  }

  resetPoints() {
    if (modolapiz) {
      pathmove = Path();
      previousOffset = const Offset(0, 0);
      inDrag = false;
      paths.clear();
    }
  }

  draw(Canvas canvas, Size size) {
    for (MapEntry<Path, Paint> path in paths) {
      Paint p = path.value;
      canvas.drawPath(path.key, p);
    }
  }
}
