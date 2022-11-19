import 'package:flutter/material.dart';
import 'package:kitit/assets/colors.dart';

class SliderM2 extends StatefulWidget {
  final ValueChanged<RangeValues> rangeValue;
  const SliderM2({super.key, required this.rangeValue});

  @override
  State<SliderM2> createState() => _SliderM2State();
}

class _SliderM2State extends State<SliderM2> {
  static double _maxValue = 800;
  static double _minValue = 300;

  RangeValues values = RangeValues(_minValue, _maxValue);
  @override
  Widget build(BuildContext context) {
    return RangeSlider(
      activeColor: DesingColors.yellow,
      inactiveColor: Color.fromARGB(255, 38, 38, 38),
      min: 100,
      max: 1000,
      divisions: 9,
      labels: RangeLabels('${values.start.round().toString()}',
          '${values.end.round().toString()}'),
      values: values,
      onChanged: (RangeValues value) {
        setState(() {
          // print('PRECIO CAMBIANDO:');
          // print(value);
          values = value;
          widget.rangeValue(value);
        });
        // print('Cambio?');
        // print(values);
        // print('Cambio?X2');
        // print(widget.rangeValue(a){print(a);});
      },
    );
  }
}
