import 'package:flutter/material.dart';
import 'package:kitit/assets/colors.dart';

class SliderPrice extends StatefulWidget {
  final ValueChanged<RangeValues> rangeValue;
  const SliderPrice({super.key, required this.rangeValue});

  @override
  State<SliderPrice> createState() => _SliderPriceState();
}

class _SliderPriceState extends State<SliderPrice> {
  static double _maxValue = 17000;
  static double _minValue = 4000;

  RangeValues values = RangeValues(_minValue, _maxValue);
  @override
  Widget build(BuildContext context) {
    return RangeSlider(
      activeColor: DesingColors.yellow,
      inactiveColor: Color.fromARGB(255, 38, 38, 38),
      min: 1000,
      max: 20000,
      divisions: 19,
      labels: RangeLabels('\$${values.start.round().toString()}',
          '\$${values.end.round().toString()}'),
      values: values,
      onChanged: (RangeValues value) {
        setState(() {
          values = value;
          widget.rangeValue(value);
        });

      },
    );
  }
}
