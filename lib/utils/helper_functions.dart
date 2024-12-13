import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

void showMessage(BuildContext context, String msg) =>
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
      ),
    );

String getFormattedDateTime(num dt, [String pattern = 'yyyy-MM-dd']) =>
    DateFormat(pattern).format(DateTime.fromMillisecondsSinceEpoch(dt.toInt()));
