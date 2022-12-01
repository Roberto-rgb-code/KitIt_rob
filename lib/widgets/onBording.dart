import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:get/get.dart';
import 'package:introduction_screen/introduction_screen.dart';

import '../service/dataSave.dart';

class onBordingData extends StatefulWidget {
  const onBordingData({super.key});

  @override
  State<onBordingData> createState() => _onBordingDataState();
}

class _onBordingDataState extends State<onBordingData> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: IntroductionScreen(
        pages: [
          page_view('Buscar', 'Informacion buscar', 'BUSCA_SIN FONDO',
              const Color(0XFF01beff)),
          page_view('Analiza', 'Informacion analiza', 'ANALIZA_SIN FONDO',
              const Color(0XFFff9f55)),
          page_view('Decide', 'Informacion decide', 'decide_sin_fondo_like',
              const Color(0XFF00d48a)),
        ],
        showSkipButton: true,
        showNextButton: false,
        skip: const Text('Saltar'),
        done: const Text('Avanzar'),
        onDone: () async {
          DataSave.setInicio();
          Navigator.popAndPushNamed(context, 'map');
          // DataSave.setInicio();
        },
        dotsDecorator: DotsDecorator(
          size: const Size.square(10.0),
          activeSize: const Size(20.0, 10.0),
          activeColor: Theme.of(context).colorScheme.secondary,
          color: Colors.black26,
          spacing: const EdgeInsets.symmetric(horizontal: 3.0),
          activeShape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.0)),
        ),
        skipStyle: TextButton.styleFrom(foregroundColor: Colors.red),
        doneStyle: TextButton.styleFrom(foregroundColor: Colors.grey),
      ),
    );
  }

  PageViewModel page_view(
      String titulo, String body, String nameImage, Color a) {
    return PageViewModel(
      title: titulo,
      body: body,
      image: Center(child: Image.asset("lib/_img/$nameImage.png")),
      decoration: PageDecoration(
        pageColor: a,
        imageFlex: 2,
        imagePadding: const EdgeInsets.only(top: 200),
        titlePadding: const EdgeInsets.only(top: 60),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 60,
        ),
        bodyTextStyle: const TextStyle(
          color: Colors.white,
        ),
      ),
    );
  }
}
