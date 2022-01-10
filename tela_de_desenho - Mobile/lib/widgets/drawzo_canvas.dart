import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/points_state.dart';
import 'current_path_paint.dart';

//tela responsavel por exibir a camada inferiro e a superior
class DrawzoCanvas extends StatelessWidget {
  const DrawzoCanvas({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    //essa classe esta  estruturada de uma forma que se uma das camadas atualiza a outra não muda.
    return Consumer<CanvasPathsState>(
      //responsavel por ouvir a classe CanvasPathsState
      builder: (_, model, child) => Stack(fit: StackFit.expand, children: [
        RepaintBoundary(
          child: CustomPaint(
            isComplex: true,
            //camada inferior ou seja ela não recebe toques, é usada para exibir os riscos apos sair da camada superior
            painter: DrawzoCanvasPainter(model.pathHistory),

            child: Container(),
          ),
        ),
        child ?? Container(),
      ]),
      child: ChangeNotifierProvider(
        create: (context) => CurrentPathState(),
        //camada superior ela recebe os toques e apos tirar o dedo da tela ela limpa e joga pra camama de baixo
        child: const CurrentPathPaint(),
      ),
    );
  }
}

class DrawzoCanvasPainter extends CustomPainter {
  final PathHistoryDois path;

  DrawzoCanvasPainter(this.path);

  @override
  void paint(Canvas canvas, Size size) {
    path.draw(canvas, size);
  }

  @override
  bool shouldRepaint(DrawzoCanvasPainter oldDelegate) => true;
}
