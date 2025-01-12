import 'package:client/l10nn/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/constants.dart';
import '../../services/models.dart';

class DiaryContainer extends StatelessWidget {
  DiaryContainer({Key? key, required this.diary, required this.onDelete, required this.onGone}) : super(key: key);
  
  void Function()? onDelete;
  void Function()? onGone;
  Diary diary;

  @override
  Widget build(BuildContext context) {
    var l = AppLocalizations.of(context)!;
    return Card(
      child: SizedBox(
        height: 25,
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Container(
                color: Provider.of<Constants>(context, listen: false).grey,
                child: Center(child: Text(diary.date.toString().substring(0, 10)))
              )
            ),
            Expanded(
              flex: 1,
              child: Container(
                color: diary.gone ? Provider.of<Constants>(context, listen: false).grey : Colors.red,
                child: Center(child: Text(diary.dId.toString()))
              )
            ),
            Expanded(
              flex: 10,
              child: Center(child: Text(diary.empName))
            ),
            Expanded(
              flex: 0,
              child: Center(child: Text(' ${l.from} '))
            ),
            Expanded(
              flex: 0,
              child: Center(child: Text(diary.startTime))
            ),
            Expanded(
              flex: 0,
              child: Center(child: Text(' ${l.to} '))
            ),
            Expanded(
              flex: 0,
              child: Center(child: Text(diary.endTime))
            ),
            const Expanded(
              flex: 1,
              child: SizedBox()
            ),
            Expanded(
              flex: 1,
              child: InkWell(
                onTap: onGone,
                child: Container(
                  color: Provider.of<Constants>(context, listen: false).grey,
                  child: Center(child: Text(l.has_gone))
                )
              )
            ),
            Expanded(
              flex: 1,
              child: InkWell(
                child: Container(
                  child: const Center(child: Icon(Icons.close)),
                  color: Provider.of<Constants>(context, listen: false).grey
                ),
                onTap: onDelete,
              )
            )
          ],
        )
      )
    );
  }
}
