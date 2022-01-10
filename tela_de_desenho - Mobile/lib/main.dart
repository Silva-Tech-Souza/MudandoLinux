import 'dart:async';
import 'dart:io';
import 'package:admob_flutter/admob_flutter.dart';
import 'package:battery/battery.dart';
import 'package:flutter/services.dart';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart' as mat show Image;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gallery_saver/gallery_saver.dart';
import '/state/points_state.dart';
import '/widgets/current_path_paint.dart';
import '/widgets/drawzo_canvas.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:photo_view/photo_view.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Tela Branca',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          highlightColor: const Color.fromRGBO(32, 176, 128, 0.8),
          primaryColor: const Color.fromRGBO(32, 176, 128, 1),
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: ChangeNotifierProvider(
          create: (_) => CanvasPathsState(),
          child: const MyHomePage(),
        ));
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

PhotoViewControllerBase? contP;
Color oldColor = Colors.black;
Color corIconeFundo = Colors.white;
//controle de visualização do meunus
bool menuAtivo = false, visivel = true;
int imageWidth = 0;
//responsavel pela movimentaçao doa img
bool imgAtiva = false, imgVisivel = false, zoomAtivo = false;
Offset offsetImg = Offset.zero;
//controle de toques das funções
bool modolapiz = true,
    ctrlModLapiz = false,
    contagotas = false,
    pintarFundo = false,
    saturacao = false,
    retasAtuando = false,
    voltarReta = false,
    retaAtiva = false;
AdmobInterstitial? anuncioTelaCheia;
AdmobInterstitial? anuncioTelaCheia2;
//controle de cores
Color corLapis = Colors.black;
Color ultimacor = Colors.black,
    corfund = Colors.black,
    pickerColor = Colors.black;
//variacel parasalvar imagem
GlobalKey keyRepaintSalvar = GlobalKey();
//controle de paint do custompainter
StrokeJoin strokeJoin = StrokeJoin.round;
StrokeCap strokeCap = StrokeCap.round;
double lapizTamanho = 4.0;
int controleFitImagem = 0;
BoxFit fitImagem = BoxFit.scaleDown;
Uint8List? imagemFundo;
bool controleFit = false;
Color corlupa = Colors.white;
bool controlerotationZoom = false;
bool controleDragZoom = true;

class _MyHomePageState extends State<MyHomePage> {
  CanvasPathsState currentPointsState = CanvasPathsState();
  CurrentPathPaint apagarReta = const CurrentPathPaint();

  //icones e cores de icones
  IconData iconModo = MdiIcons.eraser, iconTipoLapis = MdiIcons.squareRounded;
  Color coriconLap = const Color.fromRGBO(22, 122, 89, 1),
      coriconBorr = Colors.white,
      coriconReta = Colors.white,
      corBollEspessura = Colors.transparent,
      corBarraEspessura = Colors.transparent;
  //controle das cores das cores usadas no lapis
  Color c1 = Colors.black;

  Color pickerColorFundo = Colors.white;

  double sizeWMenu = 0,
      sizeHMenu = 0,
      sizeHConfig = 0.08,
      sizeHESpessura = 0,
      buttomSize = 56.0,
      spacing = 3;
  ValueNotifier<bool> isDialOpem = ValueNotifier(true);
  String nomeImagemSalvar = "TBWEB";
  final Battery _battery = Battery();
  Battery battery = Battery();
  BatteryState? _batteryState;
  AdmobInterstitial anuncioTelaCheia =
      AdmobInterstitial(adUnitId: 'ca-app-pub-3940256099942544/4411468910');
  AdmobInterstitial anuncioTelaCheia2 =
      AdmobInterstitial(adUnitId: 'ca-app-pub-3940256099942544/4411468910');
  int controleSalvarBateria = 0;

  @override
  initState() {
    super.initState();
    lapizTamanho = 4.0;
    //instancio a a variavel que eu uso para mudar o valor da class que esta sendo ouvida
    currentPointsState = Provider.of<CanvasPathsState>(context, listen: false);
    currentPointsState.pathHistory.setBackgroundColor(Colors.white);
    corIconeFundo = currentPointsState.backgroundColor;
    isDialOpem.value = true;

    /*  anuncioTelaCheia = AdmobInterstitial(
      adUnitId: getIDAnuncioTelaCheia(),
      listener: (AdmobAdEvent event, Map<String, dynamic>? args) async {
        if (event == AdmobAdEvent.closed) {
          anuncioTelaCheia.load();
        }
      },
    );
    anuncioTelaCheia2 = AdmobInterstitial(
      adUnitId: getIDAnuncioTelaCheia2(),
      listener: (AdmobAdEvent event, Map<String, dynamic>? args) async {
        if (event == AdmobAdEvent.closed) {
          anuncioTelaCheia2.load();
        }
      },
    );

    anuncioTelaCheia.load();
    anuncioTelaCheia2.load();
    batteryacheck();*/
  }

  String getIDAnuncioTelaCheia() {
    if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/4411468910';
    } else if (Platform.isAndroid) {
      return 'ca-app-pub-2977046693978514/1387637082';
      // TESfTE: ca-app-pub-3940256099942544/1033173712
      // OFICIAL: ca-app-pub-2977046693978514/1387637082
    }
    return "foi";
  }

  String getIDAnuncioTelaCheia2() {
    if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/4411468910';
    } else if (Platform.isAndroid) {
      return 'ca-app-pub-2977046693978514/7782727845';
      // TESfTE: ca-app-pub-3940256099942544/1033173712
      // OFICIAL: ca-app-pub-2977046693978514/7782727845
    }
    return "foi";
  }

  batteryacheck() async {
    _battery.onBatteryStateChanged.listen((BatteryState state) {
      setState(() async {
        if (!(await Permission.storage.status.isGranted)) {
          await Permission.storage.request();
        }

        if (!(await Permission.camera.status.isGranted)) {
          await Permission.camera.request();
        }

        if (await battery.batteryLevel <= 15 &&
            _batteryState == BatteryState.discharging &&
            controleSalvarBateria == 0) {
          _salvarImagem();
          Fluttertoast.showToast(
            msg: "Bateria baixa! Salvando Imagem...",
            textColor: Colors.white,
            backgroundColor: const Color.fromRGBO(32, 176, 128, 1),
            fontSize: 20,
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.TOP,
          );
          controleSalvarBateria = 3;
        } else {
          controleSalvarBateria--;
        }
      });
    });
  }

  Container iconsTipo(IconData icon, int tipo, Color cor) {
    //função responsavel por criar os widgets dos icones
    Container child = Container(
      margin: const EdgeInsets.fromLTRB(6, 0, 0, 6),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(32, 176, 128, 1),
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(200),
          bottomRight: Radius.circular(200),
          topLeft: Radius.circular(200),
          bottomLeft: Radius.circular(200),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: TextButton(
        onPressed: () async {
          if (tipo == 1) {
            //voltar
            currentPointsState.undo();
          }
          if (tipo == 2) {
            //avançar
            currentPointsState.redo();
          }
          if (tipo == 3) {
            //lapís
            controlerotationZoom = false;
            controleDragZoom = true;
            corlupa = Colors.white;
            zoomAtivo = false;
            imgAtiva = false;

            saturacao = false;
            sizeHESpessura = 0;
            corBollEspessura = Colors.transparent;
            corBarraEspessura = Colors.transparent;
            contagotas = false;
            sizeHConfig = 0.08;
            ctrlModLapiz = false;
            modolapiz = true;
            coriconLap = const Color.fromRGBO(22, 122, 89, 1);
            coriconBorr = Colors.white;
            coriconReta = Colors.white;
            currentPointsState.eraseMode = false;
          }
          if (tipo == 4) {
            //reta
            controlerotationZoom = false;
            corlupa = Colors.white;
            retaAtiva = true;
            zoomAtivo = false;
            imgAtiva = false;
            saturacao = false;
            sizeHESpessura = 0;
            controleDragZoom = true;
            modolapiz = false;
            corBollEspessura = Colors.transparent;
            corBarraEspessura = Colors.transparent;
            contagotas = false;
            coriconReta = const Color.fromRGBO(22, 122, 89, 1);
            currentPointsState.eraseMode = false;
            coriconLap = Colors.white;
            coriconBorr = Colors.white;
            retasAtuando = false;

            if (ctrlModLapiz) {
              ctrlModLapiz = false;
            } else {
              ctrlModLapiz = true;
            }
          }
          if (tipo == 8) {
            //pegar img

            chamarMenuFoto();
          }
          if (tipo == 7) {
            // borracha
            controlerotationZoom = false;
            corlupa = Colors.white;
            zoomAtivo = false;
            controleDragZoom = true;
            coriconLap = Colors.white;
            coriconBorr = const Color.fromRGBO(22, 122, 89, 1);
            saturacao = false;
            sizeHESpessura = 0;
            corBollEspessura = Colors.transparent;
            corBarraEspessura = Colors.transparent;
            contagotas = false;
            sizeHConfig = 0.08;
            ctrlModLapiz = false;
            modolapiz = true;
            coriconReta = Colors.white;
            currentPointsState.modeblend = BlendMode.clear;
            currentPointsState.eraseMode = true;

            imgAtiva = false;
          }
          if (tipo == 5) {
            //cor pincel
            imgAtiva = false;

            corBollEspessura = Colors.transparent;
            corBarraEspessura = Colors.transparent;
            contagotas = false;

            corLapis = currentPointsState.drawColor;
            c1 = pickerColor;
            chamarMenuCorPencil(true);

            corBollEspessura = Colors.transparent;
            corBarraEspessura = Colors.transparent;
          }
          if (tipo == 6) {
            //cor de fundo
            corBollEspessura = Colors.transparent;
            corBarraEspessura = Colors.transparent;
            contagotas = false;
            currentPointsState.backgroundColor = pickerColor;

            if (currentPointsState.backgroundColor.opacity == 0.0) {
              corIconeFundo =
                  currentPointsState.backgroundColor.withOpacity(1.0);
            } else {
              corIconeFundo = currentPointsState.backgroundColor;
            }
          }
          if (tipo == 9) {
            //zoom
            corlupa = const Color.fromRGBO(22, 122, 89, 1);
            coriconReta = Colors.white;
            controleDragZoom = false;
            controlerotationZoom = true;
          }
        },
        child: FittedBox(
          child: Icon(
            icon,
            size: 38,
            color: cor,
          ),
        ),
      ),
    );
    return child;
  }

  chamarMenuFoto() {
    visivel = false;
    buttomSize = 0;

    spacing = 0;
    isDialOpem.value = false;
    currentPointsState.backgroundColor = currentPointsState.backgroundColor;
    showModalBottomSheet(
      elevation: 80,
      enableDrag: true,
      useRootNavigator: false,
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          StateSetter _setState;
          _setState = setState;
          double valorOpacity = 1;
          try {
            valorOpacity = currentPointsState.backgroundColor.opacity;
          } catch (e) {}
          return Container(
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: Color.fromRGBO(130, 170, 150, 1),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
              ),
            ),
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height * 0.4,
            child: Column(
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.045,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(100),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  width: MediaQuery.of(context).size.width * 0.4,
                  height: MediaQuery.of(context).size.height * 0.01,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.045,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
                Container(
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: Color.fromRGBO(130, 170, 150, 1),
                  ),
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height * 0.3,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          Container(
                            decoration: const BoxDecoration(
                              color: Color.fromRGBO(130, 170, 150, 1),
                            ),
                            width: MediaQuery.of(context).size.width * 0.45,
                            height: (MediaQuery.of(context).size.height * 0.1),
                            child: TextButton(
                              child: FittedBox(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: const [
                                    Text(
                                      "CAMERA",
                                      style: TextStyle(
                                        fontSize: 22,
                                        color: Colors.white,
                                      ),
                                    ),
                                    SizedBox(
                                      width: 5,
                                    ),
                                    Icon(
                                      Icons.camera,
                                      size: 40,
                                      color: Colors.white,
                                    ),
                                  ],
                                ),
                              ),
                              onPressed: () async {
                                await getImage(0);
                                try {
                                  anuncioTelaCheia2.show();
                                } catch (e) {}

                                currentPointsState.backgroundColor =
                                    currentPointsState.backgroundColor
                                        .withOpacity(0.4);
                                Navigator.pop(context);
                              },
                            ),
                          ),
                          Container(
                            decoration: const BoxDecoration(
                              color: Color.fromRGBO(130, 170, 150, 1),
                            ),
                            width: MediaQuery.of(context).size.width * 0.45,
                            height: (MediaQuery.of(context).size.height * 0.1),
                            child: TextButton(
                              child: FittedBox(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: const [
                                    Text(
                                      "Galeria",
                                      style: TextStyle(
                                        fontSize: 22,
                                        color: Colors.white,
                                      ),
                                    ),
                                    SizedBox(
                                      width: 5,
                                    ),
                                    Icon(
                                      Icons.photo_album,
                                      size: 40,
                                      color: Colors.white,
                                    ),
                                  ],
                                ),
                              ),
                              onPressed: () async {
                                getImage(1);
                                try {
                                  anuncioTelaCheia2.show();
                                } catch (e) {}
                                currentPointsState.backgroundColor =
                                    currentPointsState.backgroundColor
                                        .withOpacity(0.4);
                                Navigator.pop(context);
                              },
                            ),
                          ),
                          Container(
                            decoration: const BoxDecoration(
                              color: Color.fromRGBO(130, 170, 150, 1),
                            ),
                            width: MediaQuery.of(context).size.width * 0.10,
                            height: (MediaQuery.of(context).size.height * 0.1),
                            child: TextButton(
                              child: FittedBox(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: const [
                                    SizedBox(
                                      width: 5,
                                    ),
                                    Icon(
                                      Icons.open_with,
                                      size: 40,
                                      color: Colors.white,
                                    ),
                                  ],
                                ),
                              ),
                              onPressed: () async {
                                if (imgVisivel) {
                                  zoomAtivo = false;
                                  imgAtiva = true;
                                  currentPointsState.drawColor =
                                      currentPointsState.drawColor;
                                }

                                Navigator.pop(context);
                              },
                            ),
                          ),
                        ],
                      ),
                      Container(
                        decoration: const BoxDecoration(
                          color: Color.fromRGBO(122, 161, 141, 1),
                        ),
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height * 0.1,
                        child: Slider(
                          value: valorOpacity,
                          onChanged: (double value) {
                            valorOpacity = value;
                            currentPointsState.backgroundColor =
                                currentPointsState.backgroundColor
                                    .withOpacity(valorOpacity);

                            currentPointsState.drawColor =
                                currentPointsState.drawColor;
                            _setState(() {});
                          },
                          min: 0.0,
                          max: 1.0,
                          activeColor: Colors.white,
                          label: valorOpacity
                              .round()
                              .toStringAsExponential(2)
                              .toString(),
                        ),
                      ),
                      Container(
                        alignment: Alignment.centerLeft,
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height * 0.1,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.all(10),
                              decoration: const BoxDecoration(
                                color: Color.fromRGBO(101, 133, 117, 1),
                              ),
                              width: MediaQuery.of(context).size.width * 0.7,
                              height:
                                  (MediaQuery.of(context).size.height * 0.1),
                              child: FittedBox(
                                fit: BoxFit.fill,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: const [
                                    Text(
                                      'preenchido',
                                      style: TextStyle(
                                          fontSize: 40, color: Colors.white),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Container(
                              alignment: Alignment.centerLeft,
                              padding: const EdgeInsets.all(10),
                              decoration: const BoxDecoration(
                                color: Color.fromRGBO(101, 133, 117, 1),
                              ),
                              width: MediaQuery.of(context).size.width * 0.3,
                              height:
                                  (MediaQuery.of(context).size.height * 0.1),
                              child: FittedBox(
                                fit: BoxFit.fill,
                                child: Switch(
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  value: controleFit,
                                  onChanged: (value) {
                                    controleFit = value;

                                    if (controleFit == true) {
                                      controleFitImagem = 0;
                                      definirFit();
                                    } else {
                                      controleFitImagem = 1;
                                      definirFit();
                                    }
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    ).then((value) => desativar());
  }

  desativar() {
    visivel = true;
    buttomSize = 56.0;
    spacing = 3;
    currentPointsState.backgroundColor = currentPointsState.backgroundColor;
  }

  definirFit() {
    if (controleFitImagem == 0) {
      setState(() {
        fitImagem = BoxFit.fill;
      });
    } else {
      setState(() {
        fitImagem = BoxFit.scaleDown;
      });
    }
  }

  final ImagePicker _picker = ImagePicker();
  getImage(int tipo) async {
    PickedFile? pickedFile;
    if (tipo == 0) {
      pickedFile = await _picker.getImage(source: ImageSource.camera);
      currentPointsState.backgroundColor =
          currentPointsState.backgroundColor.withOpacity(0.4);
    } else if (tipo == 1) {
      pickedFile = await _picker.getImage(source: ImageSource.gallery);
      currentPointsState.backgroundColor =
          currentPointsState.backgroundColor.withOpacity(0.4);
    }

    File? cropped = await ImageCropper.cropImage(
      sourcePath: pickedFile!.path,
      compressQuality: 100,
      maxHeight: 2800,
      maxWidth: 2800,
      compressFormat: ImageCompressFormat.jpg,
    );
    imagemFundo = cropped!.readAsBytesSync();
    currentPointsState.backgroundColor = currentPointsState.backgroundColor;

    imgVisivel = true;
  }

  chamarMenuCorPencil(bool modo) {
    visivel = false;
    buttomSize = 0;

    spacing = 0;
    isDialOpem.value = false;
    currentPointsState.backgroundColor = currentPointsState.backgroundColor;

    //funçao para escolher uma cor
    showModalBottomSheet(
      elevation: 100,
      enableDrag: true,
      useRootNavigator: false,
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height * 0.7,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: Color.fromRGBO(130, 194, 180, 1),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
            ),
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.fromLTRB(0, 15, 0, 25),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(100),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  width: MediaQuery.of(context).size.width * 0.5,
                  height: MediaQuery.of(context).size.height * 0.0099,
                  child: GestureDetector(
                    onTap: () {
                      try {
                        Navigator.pop(context);
                      } catch (e) {}
                    },
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height * 0.09,
                  decoration: const BoxDecoration(
                    color: Color.fromRGBO(32, 176, 128, 1),
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(95),
                      bottomRight: Radius.circular(95),
                    ),
                  ),
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      Container(
                        height: MediaQuery.of(context).size.height * 0.06,
                        margin: const EdgeInsets.fromLTRB(6, 0, 6, 0),
                        decoration: const BoxDecoration(
                          color: Color.fromRGBO(20, 160, 100, 1),
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(200),
                            bottomRight: Radius.circular(200),
                            topLeft: Radius.circular(200),
                            bottomLeft: Radius.circular(200),
                          ),
                        ),
                        child: TextButton(
                          onPressed: () async {
                            zoomAtivo = false;
                            contagotas = true;
                            currentPointsState.eraseMode = false;
                            Navigator.pop(context);
                          },
                          child: const FittedBox(
                            child: Icon(
                              MdiIcons.eyedropper,
                              size: 38,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          try {
                            controleDragZoom = false;
                            currentPointsState.drawColor = ultimacor;
                            corfund = ultimacor;
                            pickerColor = ultimacor;
                            if (currentPointsState.drawColor.opacity == 0.0) {
                              corLapis =
                                  currentPointsState.drawColor.withOpacity(1.0);
                            } else {
                              corLapis = currentPointsState.drawColor;
                            }

                            Navigator.pop(context);
                          } catch (e) {}
                        },
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.09,
                          height: MediaQuery.of(context).size.height * 0.06,
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.only(
                              topRight: Radius.circular(200),
                              bottomRight: Radius.circular(200),
                              topLeft: Radius.circular(200),
                              bottomLeft: Radius.circular(200),
                            ),
                            color: ultimacor,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          try {
                            currentPointsState.drawColor = Colors.amber;
                            corfund = Colors.amber;
                            pickerColor = Colors.amber;
                            corLapis = currentPointsState.drawColor;
                            Navigator.pop(context);
                          } catch (e) {}
                        },
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.09,
                          height: MediaQuery.of(context).size.height * 0.06,
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(200),
                              bottomRight: Radius.circular(200),
                              topLeft: Radius.circular(200),
                              bottomLeft: Radius.circular(200),
                            ),
                            color: Colors.amber,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          try {
                            currentPointsState.drawColor = Colors.blue;
                            corfund = Colors.blue;
                            pickerColor = Colors.blue;
                            corLapis = currentPointsState.drawColor;
                            Navigator.pop(context);
                          } catch (e) {}
                        },
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.09,
                          height: MediaQuery.of(context).size.height * 0.06,
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(200),
                              bottomRight: Radius.circular(200),
                              topLeft: Radius.circular(200),
                              bottomLeft: Radius.circular(200),
                            ),
                            color: Colors.blue,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          try {
                            currentPointsState.drawColor = Colors.brown;
                            corfund = Colors.brown;
                            pickerColor = Colors.brown;
                            corLapis = currentPointsState.drawColor;
                            Navigator.pop(context);
                          } catch (e) {}
                        },
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.09,
                          height: MediaQuery.of(context).size.height * 0.06,
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(200),
                              bottomRight: Radius.circular(200),
                              topLeft: Radius.circular(200),
                              bottomLeft: Radius.circular(200),
                            ),
                            color: Colors.brown,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          try {
                            currentPointsState.drawColor = Colors.green;
                            corfund = Colors.green;
                            pickerColor = Colors.green;
                            corLapis = currentPointsState.drawColor;
                            Navigator.pop(context);
                          } catch (e) {}
                        },
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.09,
                          height: MediaQuery.of(context).size.height * 0.06,
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(200),
                              bottomRight: Radius.circular(200),
                              topLeft: Radius.circular(200),
                              bottomLeft: Radius.circular(200),
                            ),
                            color: Colors.green,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          try {
                            currentPointsState.drawColor = Colors.red;
                            corfund = Colors.red;
                            pickerColor = Colors.red;
                            corLapis = currentPointsState.drawColor;
                            Navigator.pop(context);
                          } catch (e) {}
                        },
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.09,
                          height: MediaQuery.of(context).size.height * 0.06,
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(200),
                              bottomRight: Radius.circular(200),
                              topLeft: Radius.circular(200),
                              bottomLeft: Radius.circular(200),
                            ),
                            color: Colors.red,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          try {
                            currentPointsState.drawColor = Colors.deepOrange;
                            corfund = Colors.deepOrange;
                            pickerColor = Colors.deepOrange;
                            corLapis = currentPointsState.drawColor;
                            Navigator.pop(context);
                          } catch (e) {}
                        },
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.09,
                          height: MediaQuery.of(context).size.height * 0.06,
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(200),
                              bottomRight: Radius.circular(200),
                              topLeft: Radius.circular(200),
                              bottomLeft: Radius.circular(200),
                            ),
                            color: Colors.deepOrange,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          try {
                            currentPointsState.drawColor = Colors.deepPurple;
                            corfund = Colors.deepPurple;
                            pickerColor = Colors.deepPurple;
                            corLapis = currentPointsState.drawColor;
                            Navigator.pop(context);
                          } catch (e) {}
                        },
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.09,
                          height: MediaQuery.of(context).size.height * 0.06,
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(200),
                              bottomRight: Radius.circular(200),
                              topLeft: Radius.circular(200),
                              bottomLeft: Radius.circular(200),
                            ),
                            color: Colors.deepPurple,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          try {
                            currentPointsState.drawColor = Colors.grey;
                            corfund = Colors.grey;
                            pickerColor = Colors.grey;
                            corLapis = currentPointsState.drawColor;
                            Navigator.pop(context);
                          } catch (e) {}
                        },
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.09,
                          height: MediaQuery.of(context).size.height * 0.06,
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(200),
                              bottomRight: Radius.circular(200),
                              topLeft: Radius.circular(200),
                              bottomLeft: Radius.circular(200),
                            ),
                            color: Colors.grey,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          try {
                            currentPointsState.drawColor = Colors.pink;
                            corfund = Colors.pink;
                            pickerColor = Colors.pink;
                            corLapis = currentPointsState.drawColor;
                            Navigator.pop(context);
                          } catch (e) {}
                        },
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.09,
                          height: MediaQuery.of(context).size.height * 0.06,
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(200),
                              bottomRight: Radius.circular(200),
                              topLeft: Radius.circular(200),
                              bottomLeft: Radius.circular(200),
                            ),
                            color: Colors.pink,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          try {
                            currentPointsState.drawColor = Colors.black;
                            corfund = Colors.black;
                            pickerColor = Colors.black;
                            corLapis = currentPointsState.drawColor;
                            Navigator.pop(context);
                          } catch (e) {}
                        },
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.09,
                          height: MediaQuery.of(context).size.height * 0.06,
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(200),
                              bottomRight: Radius.circular(200),
                              topLeft: Radius.circular(200),
                              bottomLeft: Radius.circular(200),
                            ),
                            color: Colors.black,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          try {
                            currentPointsState.drawColor = Colors.white;
                            corfund = Colors.white;
                            pickerColor = Colors.white;
                            corLapis = currentPointsState.drawColor;
                            Navigator.pop(context);
                          } catch (e) {}
                        },
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.09,
                          height: MediaQuery.of(context).size.height * 0.06,
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(200),
                              bottomRight: Radius.circular(200),
                              topLeft: Radius.circular(200),
                              bottomLeft: Radius.circular(200),
                            ),
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  alignment: Alignment.center,
                  margin: const EdgeInsets.fromLTRB(5, 8, 5, 5),
                  decoration: const BoxDecoration(
                    color: Color.fromRGBO(130, 194, 180, 1),
                  ),
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height * 0.49,
                  child: Center(
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ColorPicker(
                            pickerColor: pickerColor,
                            onColorChanged: changeColor,
                            displayThumbColor: true,
                            colorPickerWidth:
                                MediaQuery.of(context).size.width * 0.80,
                            pickerAreaHeightPercent:
                                (MediaQuery.of(context).size.height * 0.38) *
                                    0.002,
                            pickerAreaBorderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(7.0),
                              topRight: Radius.circular(7.0),
                              bottomLeft: Radius.circular(7.0),
                              bottomRight: Radius.circular(7.0),
                            ),
                          ),
                        ]),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    ).then((value) => ultimaCor(value));
  }

  ultimaCor(value) {
    visivel = true;
    buttomSize = 56.0;
    spacing = 3;

    //função que é chamada apos fechar o dialogo , responsavel por salvar a ultima cor
    try {
      if (c1 != pickerColor) {
        ultimacor = c1;
      } else {}
      currentPointsState.drawColor = currentPointsState.drawColor;
    } catch (e) {}
  }

  changeColor(Color color) {
    try {
      pickerColor = color;
      corfund = color;

      if (color.opacity == 0.0) {
        corLapis = color.withOpacity(1.0);
      } else {
        corLapis = color;
      }
      currentPointsState.drawColor = corLapis;
    } catch (e) {}
  }

  _mostrarDialogoApagarDesenho() async {
    await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: const EdgeInsets.all(16.0),
          content: Row(
            children: const [
              Expanded(
                child: Text('Deseja apagar o desenho?',
                    style: TextStyle(fontSize: 25)),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
                child: const Text('Não', style: TextStyle(fontSize: 22)),
                onPressed: () {
                  Navigator.pop(context);
                }),
            TextButton(
                child: const Text('Sim', style: TextStyle(fontSize: 25)),
                onPressed: () async {
                  imgVisivel = false;
                  currentPointsState.pathHistory.limpar();
                  currentPointsState.notifyList();
                  saturacao = false;
                  sizeHESpessura = 0;
                  corBollEspessura = Colors.transparent;
                  corBarraEspessura = Colors.transparent;
                  contagotas = false;
                  sizeHConfig = 0.08;
                  ctrlModLapiz = false;
                  modolapiz = true;
                  coriconLap = const Color.fromRGBO(22, 122, 89, 1);
                  coriconBorr = Colors.white;
                  coriconReta = Colors.white;
                  currentPointsState.eraseMode = false;
                  Navigator.pop(context);
                })
          ],
        );
      },
    );
  }

  void _chamarDefinirEspessuraPincel() {
    visivel = false;
    buttomSize = 0;

    spacing = 0;
    isDialOpem.value = false;
    currentPointsState.backgroundColor = currentPointsState.backgroundColor;

    showModalBottomSheet(
      elevation: 80,
      enableDrag: false,
      useRootNavigator: false,
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        alignment: Alignment.bottomCenter,
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Column(
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height * 0.8,
              child: GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ),
            Container(
              decoration: const BoxDecoration(
                color: Color.fromRGBO(130, 194, 180, 1),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(15),
                  topRight: Radius.circular(15),
                ),
              ),
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height * 0.2,
              child: Column(
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.045,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(100),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    width: MediaQuery.of(context).size.width * 0.4,
                    height: MediaQuery.of(context).size.height * 0.01,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.045,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                  Container(
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: Color.fromRGBO(130, 194, 180, 1),
                    ),
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height * 0.1,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(
                          child: StatefulBuilder(builder:
                              (BuildContext context, StateSetter setState) {
                            return Container(
                              child: Slider(
                                value: currentPointsState.thickness,
                                onChanged: (double value) => setState(() {
                                  currentPointsState.thickness = value;
                                  setState(() {
                                    lapizTamanho = value;
                                    currentPointsState.thickness = value;
                                  });
                                }),
                                min: 1.0,
                                max: 100.0,
                                divisions: 100,
                                label: currentPointsState.thickness
                                    .round()
                                    .toString(),
                                activeColor: Colors.white,
                              ),
                            );
                          }),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ).then((value) => desativar());
  }

  Future<void> _salvarImagem() async {
    try {
      RenderRepaintBoundary boundary = keyRepaintSalvar.currentContext!
          .findRenderObject() as RenderRepaintBoundary;

      final image = await boundary.toImage(pixelRatio: 4);

      final ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);

      final Uint8List pngBytes = byteData!.buffer.asUint8List();

      if (!(await Permission.storage.status.isGranted)) {
        await Permission.storage.request();
      }
      try {
        String varNome =
            'Branca${DateTime.now().day}_${DateTime.now().hour}_${DateTime.now().millisecond}.png';

        String fullPath = '/storage/emulated/0/$varNome';

        File capturedFile = File(fullPath);

        try {
          capturedFile.writeAsBytesSync(
            Uint8List.fromList(pngBytes),
            flush: true,
          );
        } catch (e) {}

        try {
          await GallerySaver.saveImage(
            // Novo salvar
            capturedFile.path,
            albumName: 'Tela Branca',
          ).then((bool? success) {});
          capturedFile.delete();
        } catch (e) {}
      } catch (e) {}
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    var sizeW = MediaQuery.of(context).size.width;
    var sizeH = MediaQuery.of(context).size.height;

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: []); //sem barra notificacao
    SystemChrome.setPreferredOrientations([
      //posiçao da tela
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return Scaffold(
      body: SingleChildScrollView(
        reverse: true,
        child: Column(
          children: [
            Container(
              color: Colors.white,
              width: sizeW,
              height: sizeH,
              child: Stack(
                alignment: Alignment.topLeft,
                children: [
                  SizedBox(
                    width: sizeW,
                    height: sizeH,
                    child: RepaintBoundary(
                      key: keyRepaintSalvar,
                      child: Consumer<CanvasPathsState>(
                        builder: (_, model, child) => PhotoView.customChild(
                          controller: contP,
                          enableRotation: controlerotationZoom,
                          disableGestures: controleDragZoom,
                          child: Stack(
                            alignment: Alignment.topLeft,
                            children: [
                              Positioned(
                                left: offsetImg.dx,
                                top: offsetImg.dy,
                                child: imgVisivel
                                    ? Container(
                                        width: sizeW,
                                        height: sizeH,
                                        decoration: BoxDecoration(
                                          image: DecorationImage(
                                            image:
                                                mat.Image.memory(imagemFundo!)
                                                    .image,
                                            fit: fitImagem,
                                          ),
                                        ),
                                      )
                                    : Container(),
                              ),
                              SizedBox(
                                width: sizeW,
                                height: sizeH,
                                child: Container(
                                  width: sizeW,
                                  height: sizeH,
                                  color: currentPointsState.backgroundColor,
                                ),
                              ),
                              SizedBox(
                                width: sizeW,
                                height: sizeH,
                                //widget responsavel por chamar as telas de pintura
                                child: const DrawzoCanvas(),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    //barra icones
                    bottom: 1,
                    left: 0,
                    child: Consumer<CanvasPathsState>(
                      //responsavel por mudar os estados dos icones caso mude algo
                      builder: (_, model, child) => AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        alignment: Alignment.center,
                        width: sizeW * 0.78,
                        height: sizeHMenu * 0.08,
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(200),
                            bottomRight: Radius.circular(200),
                          ),
                        ),
                        child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: [
                              iconsTipo(Icons.undo, 1, Colors.white),
                              iconsTipo(Icons.redo, 2, Colors.white),
                              iconsTipo(MdiIcons.magnifyPlus, 9, corlupa),
                              iconsTipo(Icons.create, 3, coriconLap),
                              iconsTipo(MdiIcons.eraser, 7, coriconBorr),
                              iconsTipo(Icons.timeline, 4, coriconReta),
                              iconsTipo(MdiIcons.palette, 5, corLapis),
                              iconsTipo(Icons.format_paint, 6, corIconeFundo),
                              iconsTipo(Icons.image_search, 8, Colors.white),
                            ]),
                      ),
                    ),
                  ),
                  Positioned(
                    //configuração
                    top: 0,
                    right: 0,
                    child: Container(
                      margin: const EdgeInsets.fromLTRB(0, 5, 5, 0),
                      height: sizeH * 0.08,
                      alignment: Alignment.center,
                      child: Consumer<CanvasPathsState>(
                        builder: (_, model, child) => SpeedDial(
                          icon: Icons.settings,
                          activeIcon: Icons.close,
                          spacing: spacing,
                          buttonSize: buttomSize,
                          childrenButtonSize: buttomSize,
                          direction: SpeedDialDirection.down,
                          foregroundColor: Colors.white,
                          backgroundColor:
                              const Color.fromRGBO(32, 176, 128, 1),
                          childPadding: const EdgeInsets.all(5),
                          spaceBetweenChildren: 4,
                          elevation: 0,
                          isOpenOnStart: false,
                          animationSpeed: 180,
                          overlayColor: Colors.transparent,
                          renderOverlay: false,
                          shape: const CircleBorder(),
                          visible: visivel,
                          openCloseDial: visivel ? null : isDialOpem,
                          onOpen: () {
                            try {
                              corBollEspessura =
                                  const Color.fromRGBO(32, 176, 128, 1);
                              corBarraEspessura =
                                  const Color.fromRGBO(10, 176, 128, 0.7);
                              //toda vez que eu abro o meu eu ativo os respectivos widgets
                              sizeHESpessura = 0.08;
                              currentPointsState.drawColor =
                                  currentPointsState.drawColor;
                            } catch (e) {}
                          },
                          onClose: () {
                            try {
                              corBollEspessura = Colors.transparent;
                              corBarraEspessura = Colors.transparent;
                              //toda vez que eu fecho o meu eu desativo os respectivos widgets
                              sizeHESpessura = 0;
                              currentPointsState.drawColor =
                                  currentPointsState.drawColor;
                            } catch (e) {}
                          },
                          children: [
                            SpeedDialChild(
                              foregroundColor: Colors.white,
                              backgroundColor:
                                  const Color.fromRGBO(32, 176, 128, 1),
                              child: Icon(iconTipoLapis, color: Colors.white),
                              label: "Lapís Quadrado/Retângulo",
                              onTap: () {
                                controlerotationZoom = false;
                                controleDragZoom = true;
                                // responsavel por mudar a forma do lapis
                                try {
                                  if (strokeJoin == StrokeJoin.round) {
                                    iconTipoLapis = Icons.circle;
                                    strokeJoin = StrokeJoin.miter;
                                    strokeCap = StrokeCap.square;
                                    currentPointsState.strokeCapMode =
                                        StrokeCap.square;
                                    currentPointsState.strokeJoinMode =
                                        StrokeJoin.bevel;
                                  } else {
                                    iconTipoLapis = MdiIcons.squareRounded;
                                    strokeJoin = StrokeJoin.round;
                                    strokeCap = StrokeCap.round;
                                    currentPointsState.strokeCapMode =
                                        StrokeCap.round;
                                    currentPointsState.strokeJoinMode =
                                        StrokeJoin.round;
                                  }
                                } catch (e) {}
                              },
                            ),
                            SpeedDialChild(
                                foregroundColor: Colors.white,
                                backgroundColor:
                                    const Color.fromRGBO(32, 176, 128, 1),
                                child: const Icon(Icons.auto_fix_high,
                                    color: Colors.white),
                                label: "Preto e Branco",
                                onTap: () {
                                  controlerotationZoom = false;
                                  controleDragZoom = true;
                                  currentPointsState.eraseMode = true;
                                  saturacao = true;
                                  pintarFundo = false;
                                  currentPointsState.modeblend =
                                      BlendMode.saturation;
                                }),
                            SpeedDialChild(
                                foregroundColor: Colors.white,
                                backgroundColor:
                                    const Color.fromRGBO(32, 176, 128, 1),
                                child: const Icon(MdiIcons.draw,
                                    color: Colors.white),
                                label: "Pintar Fundo",
                                onTap: () {
                                  controlerotationZoom = false;
                                  controleDragZoom = true;
                                  currentPointsState.eraseMode = true;
                                  pintarFundo = true;
                                  saturacao = false;
                                  currentPointsState.modeblend =
                                      BlendMode.dstATop;
                                }),
                            SpeedDialChild(
                                foregroundColor: Colors.white,
                                backgroundColor:
                                    const Color.fromRGBO(32, 176, 128, 1),
                                child: const Icon(Icons.open_in_full,
                                    color: Colors.white),
                                label: "Tamanho do Lapís",
                                onTap: () {
                                  _chamarDefinirEspessuraPincel();
                                }),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Consumer<CanvasPathsState>(
        builder: (_, model, child) => SpeedDial(
          icon: Icons.add,
          activeIcon: Icons.close,
          spacing: spacing,
          foregroundColor: Colors.white,
          backgroundColor: corLapis.opacity == 0.0
              ? corLapis.withOpacity(1)
              : corLapis == corIconeFundo
                  ? corLapis
                  : corLapis,
          childPadding: const EdgeInsets.all(5),
          spaceBetweenChildren: 4,
          elevation: 0,
          animationSpeed: 180,
          childrenButtonSize: buttomSize,
          buttonSize: buttomSize,
          overlayColor: Colors.transparent,
          isOpenOnStart: true,
          renderOverlay: false,
          openCloseDial: visivel ? null : isDialOpem,
          shape: const CircleBorder(),
          visible: visivel,
          onOpen: () {
            try {
              menuAtivo = true;
              sizeWMenu = MediaQuery.of(context).size.width;
              sizeHMenu = MediaQuery.of(context).size.height;
              currentPointsState.drawColor = currentPointsState.drawColor;
            } catch (e) {}
          },
          onClose: () {
            try {
              menuAtivo = false;
              sizeWMenu = 0.0;
              sizeHMenu = 0.0;
              currentPointsState.drawColor = currentPointsState.drawColor;
            } catch (e) {}
          },
          children: [
            SpeedDialChild(
              foregroundColor: Colors.white,
              backgroundColor: const Color.fromRGBO(32, 176, 128, 1),
              child: const Icon(Icons.delete, color: Colors.white),
              label: visivel ? "Apagar" : null,
              onTap: () {
                _mostrarDialogoApagarDesenho();
              },
            ),
            SpeedDialChild(
              foregroundColor: Colors.white,
              backgroundColor: const Color.fromRGBO(32, 176, 128, 1),
              child: const Icon(Icons.save, color: Colors.white),
              label: visivel ? "Salvar" : null,
              onTap: () async {
                _salvarImagem();
                showModalBottomSheet(
                  context: context,
                  builder: (BuildContext context) => Icon(
                    Icons.check_circle,
                    size: sizeW * 0.15,
                    color: Colors.green[400],
                  ),
                );
                try {
                  anuncioTelaCheia.show();
                } catch (e) {}
              },
            ),
          ],
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
