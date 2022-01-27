import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '/main.dart';
import '/state/points_state.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import 'dart:ui' as ui;

bool emrisco = false;

class OnlyOnePointerRecognizer extends OneSequenceGestureRecognizer {
  int _p = 0;
  @override
  void addPointer(PointerDownEvent event) {
    startTrackingPointer(event.pointer);
    if (_p == 0) {
      resolve(GestureDisposition.rejected);
      _p = event.pointer;
    } else {
      resolve(GestureDisposition.accepted);
    }
  }

  @override
  String get debugDescription => 'only one pointer recognizer';

  @override
  void didStopTrackingLastPointer(int pointer) {}

  @override
  void handleEvent(PointerEvent event) {
    if (!event.down && event.pointer == _p) {
      _p = 0;
    }
  }
}

@override
class CurrentPathPaint extends StatelessWidget {
  const CurrentPathPaint({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    CurrentPathState currentPointsState =
        Provider.of<CurrentPathState>(context, listen: false);
    CanvasPathsState mainPointsState =
        Provider.of<CanvasPathsState>(context, listen: false);

    return Consumer<CurrentPathState>(
      builder: (_, model, child) => Stack(
        fit: StackFit.expand,
        children: [
          RepaintBoundary(
              child: CustomPaint(
            isComplex: true,
            painter: CurrentPathPainter(model.pathHistory),
            child: Container(),
          )),
          child ?? Container(),
        ],
      ),
      child: RawGestureDetector(
        gestures: <Type, GestureRecognizerFactory>{
          OnlyOnePointerRecognizer:
              GestureRecognizerFactoryWithHandlers<OnlyOnePointerRecognizer>(
            () => OnlyOnePointerRecognizer(),
            (OnlyOnePointerRecognizer instance) {},
          ),
        },
        child: GestureDetector(
          onPanStart: !imgAtiva
              ? (details) async {
                  if (!imgAtiva) {
                    if (emrisco) {
                      emrisco = false;
                    } else {
                      emrisco = true;
                    }
                    if (contagotas) {
                      Offset localclique = details.globalPosition;

                      RenderRepaintBoundary boundary =
                          keyRepaintSalvar.currentContext!.findRenderObject()
                              as RenderRepaintBoundary;
                      ui.Image image = await boundary.toImage();
                      final rgbaImageData = await image.toByteData(
                          format: ui.ImageByteFormat.rawRgba);
                      imageWidth = image.width;
                      Uint32List words = Uint32List.view(
                          rgbaImageData!.buffer,
                          rgbaImageData.offsetInBytes,
                          rgbaImageData.lengthInBytes ~/
                              Uint32List.bytesPerElement);
                      int x = localclique.dx.toInt();
                      int y = localclique.dy.toInt();
                      var offset = x + y * imageWidth;
                      oldColor = Color(words[offset]);

                      List<String> cores = oldColor.toString().split('xff');
                      cores = cores[1].toString().split(')');
                      String r = cores[0].toString().substring(0, 2);
                      String g = cores[0].toString().substring(2, 4);
                      String b = cores[0].toString().substring(4, 6);
                      String colorString = "Color(0xff$b$g$r)";
                      colorString = colorString.split('(0x')[1].split(')')[0];
                      int value = int.parse(colorString, radix: 16);
                      oldColor = Color(value);
                      currentPointsState.drawColor = oldColor;
                      currentPointsState.eraseMode = false;
                      corLapis = currentPointsState.drawColor;
                      pickerColor = currentPointsState.drawColor;
                      currentPointsState.drawColor = oldColor;
                      mainPointsState.drawColor = oldColor;
                      currentPointsState.drawColor = oldColor;
                      mainPointsState.drawColor = oldColor;
                      corfund = oldColor;
                      corIconeFundo = oldColor;
                      contagotas = false;
                    } else {
                      try {
                        if (currentPointsState.thickness != lapizTamanho ||
                            currentPointsState.drawColor != pickerColor ||
                            currentPointsState.strokeJoinMode != strokeJoin ||
                            corLapis != currentPointsState.drawColor ||
                            corLapis != mainPointsState.drawColor) {
                          currentPointsState.thickness = lapizTamanho;
                          currentPointsState.drawColor = pickerColor;
                          currentPointsState.strokeJoinMode = strokeJoin;
                        }
                        if (modolapiz) {
                          if (!mainPointsState.eraseMode) {
                            //se a borracha estiver desativada
                            if (ctrlModLapiz) {
                              mainPointsState.pathHistory.addPath(
                                  currentPointsState.pathHistory.paths);
                              mainPointsState.notifyList();
                              currentPointsState.pathHistory.resetPoints();
                              currentPointsState.notifyList();
                              modolapiz = false;
                              currentPointsState.pathHistory
                                  .adicionar(details.localPosition);
                              currentPointsState.notifyList();
                              currentPointsState.pathHistory
                                  .updateCurrent(details.localPosition);
                              currentPointsState.notifyList();
                            } else {
                              currentPointsState.pathHistory
                                  .adicionar(details.localPosition);
                              currentPointsState.notifyList();
                              currentPointsState.pathHistory
                                  .updateCurrent(details.localPosition);
                              currentPointsState.notifyList();
                            }
                          } else {
                            if (ctrlModLapiz) {
                              mainPointsState.pathHistory
                                  .adicionar(details.localPosition);
                              mainPointsState.notifyList();
                              mainPointsState.pathHistory
                                  .updateCurrent(details.localPosition);
                              mainPointsState.notifyList();
                            } else {
                              mainPointsState.pathHistory.addPath(
                                  currentPointsState.pathHistory.paths);
                              retasAtuando = false;
                              mainPointsState.notifyList();
                              currentPointsState.pathHistory.resetPoints();
                              currentPointsState.notifyList();
                              mainPointsState.pathHistory
                                  .adicionar(details.localPosition);
                              mainPointsState.notifyList();
                              mainPointsState.pathHistory
                                  .updateCurrent(details.localPosition);
                              mainPointsState.notifyList();
                            }
                          }
                        } else {
                          mainPointsState.pathHistory
                              .adicionar(details.localPosition);
                          mainPointsState.notifyList();
                        }
                      } catch (e) {}
                    }
                  } else if (contagotas) {
                    Offset localclique = details.globalPosition;
                    RenderRepaintBoundary boundary =
                        keyRepaintSalvar.currentContext!.findRenderObject()
                            as RenderRepaintBoundary;
                    ui.Image image = await boundary.toImage();
                    final rgbaImageData = await image.toByteData(
                        format: ui.ImageByteFormat.rawRgba);
                    imageWidth = image.width;
                    Uint32List words = Uint32List.view(
                        rgbaImageData!.buffer,
                        rgbaImageData.offsetInBytes,
                        rgbaImageData.lengthInBytes ~/
                            Uint32List.bytesPerElement);
                    int x = localclique.dx.toInt();
                    int y = localclique.dy.toInt();
                    var offset = x + y * imageWidth;
                    oldColor = Color(words[offset]);
                    List<String> cores = oldColor.toString().split('xff');
                    cores = cores[1].toString().split(')');
                    String r = cores[0].toString().substring(0, 2);
                    String g = cores[0].toString().substring(2, 4);
                    String b = cores[0].toString().substring(4, 6);
                    String colorString = "Color(0xff$b$g$r)";
                    colorString = colorString.split('(0x')[1].split(')')[0];
                    int value = int.parse(colorString, radix: 16);
                    oldColor = Color(value);
                    currentPointsState.drawColor = oldColor;
                    currentPointsState.eraseMode = false;
                    corLapis = currentPointsState.drawColor;
                    pickerColor = currentPointsState.drawColor;
                    currentPointsState.drawColor = oldColor;
                    mainPointsState.drawColor = oldColor;
                    currentPointsState.drawColor = oldColor;
                    mainPointsState.drawColor = oldColor;
                    corfund = oldColor;
                    corIconeFundo = oldColor;
                    contagotas = false;
                  }
                }
              : null,
          onPanUpdate: !contagotas
              ? (details) {
                  if (!imgAtiva) {
                    if (emrisco) {
                      try {
                        if (!mainPointsState.eraseMode) {
                          currentPointsState.pathHistory
                              .adicionar(details.localPosition);
                          currentPointsState.notifyList();
                          currentPointsState.pathHistory
                              .updateCurrent(details.localPosition);
                          currentPointsState.notifyList();
                        } else {
                          mainPointsState.pathHistory
                              .adicionar(details.localPosition);
                          mainPointsState.notifyList();
                          mainPointsState.pathHistory
                              .updateCurrent(details.localPosition);
                          mainPointsState.notifyList();
                        }
                      } catch (e) {}
                    }
                  } else {
                    offsetImg = Offset(offsetImg.dx + details.delta.dx,
                        offsetImg.dy + details.delta.dy);
                    mainPointsState.drawColor = mainPointsState.drawColor;
                  }
                }
              : null,
          onPanEnd: !contagotas & !imgAtiva
              ? (details) {
                  if (!imgAtiva) {
                    try {
                      emrisco = false;
                      if (!mainPointsState.eraseMode) {
                        mainPointsState.pathHistory
                            .addPath(currentPointsState.pathHistory.paths);
                        mainPointsState.notifyList();
                        currentPointsState.pathHistory.resetPoints();
                        currentPointsState.notifyList();
                      } else {
                        mainPointsState.pathHistory.resetPoints();
                        mainPointsState.notifyList();
                      }
                    } catch (e) {}
                  }
                }
              : null,
        ),
      ),
    );
  }
}

class CurrentPathPainter extends CustomPainter {
  final PathHistory _path;

  CurrentPathPainter(this._path);

  @override
  void paint(Canvas canvas, Size size) {
    _path.draw(canvas, size);
  }

  @override
  bool shouldRepaint(CurrentPathPainter oldDelegate) => true;
}
