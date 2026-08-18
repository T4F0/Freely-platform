// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';

class FilterList extends StatefulWidget {
  final title;
  final List options;
  var square_checkbox = false;
  Function onSelectFilter;
  FilterList({
    super.key,
    required this.title,
    required this.options,
    required this.onSelectFilter,
    this.square_checkbox = false,
    
  });

  @override
  State<FilterList> createState() => _FilterListState();
}

class _FilterListState extends State<FilterList> {
  late List<bool> checkbox_values;

  @override
  void initState() {
    checkbox_values = List.filled(widget.options.length, false);
    checkbox_values[0] = true;
    super.initState();
  }

  on_select_checkbox(idx, val) {
    setState(() {
      checkbox_values = List.filled(widget.options.length, false);
      checkbox_values[idx] = val;
      widget.onSelectFilter(idx);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        ...widget.options.asMap().entries.map((entry) {
          var idx = entry.key;
          var option = entry.value;
          return GestureDetector(
            onTap: () => on_select_checkbox(idx, !checkbox_values[idx]),
            child: Container(
              height: 40,
              margin: EdgeInsets.only(left: 15),
              child: Row(
                children: [
                  CustomCheckBox(
                    on_change: (val) { on_select_checkbox(idx, !checkbox_values[idx]);},
                    value: checkbox_values[idx] as bool,
                    square_shape: widget.square_checkbox,
                  ),
                  SizedBox(width: 10),
                  Text(
                    option,
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}

class CustomCheckBox extends StatelessWidget {
  final value;
  final on_change;
  var square_shape;
  CustomCheckBox({
    super.key,
    required this.value,
    required this.on_change,
    this.square_shape = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap:  () => on_change(!value),
      child: Container(
        width: 18,
        height: 18,
        decoration: BoxDecoration(
          border: Border.all(
            width: 1,
            color: Colors.grey.withOpacity(0.5),
          ),
          borderRadius: !square_shape ?  BorderRadius.circular(100) : BorderRadius.circular(2),
          color: value ? Color(0xFFc499f3) : Colors.white,
        ),
        child: Center(
          child: Container(
            width: !square_shape ? 6 : 10 ,
            height: !square_shape ? 6 : 10 ,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: !square_shape ? BorderRadius.circular(100)  : BorderRadius.circular(0),
            ),
          ),
        ),
      ),
    );
  }
}
