import 'package:flutter/material.dart';
import 'package:client/store/groceries/grocery_states_events.dart';
import 'package:client/store/store_bloc.dart';
import 'package:client/store/store_states_events.dart';
import 'package:client/store/widgets/my_text_field.dart';
import 'package:client/widgets/gram_liter_dropdown.dart';
import 'package:provider/provider.dart';

import '../../bloc_provider.dart';
import '../../services/constants.dart';
import '../../services/models.dart';
import '../../services/repo.dart';
import 'grocery_bloc.dart';

class GroceryDialog extends StatefulWidget {
  const GroceryDialog({Key? key, required this.id}) : super(key: key);

  final int id;

  @override
  State<GroceryDialog> createState() => _GroceryDialogState();
}

class _GroceryDialogState extends State<GroceryDialog> {
  
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      // bloc: GroceryBloc(Provider.of<Repo>(context),widget.id),
      blocBuilder: () => GroceryBloc(Provider.of<Repo>(context),widget.id),
      blocDispose: (GroceryBloc bloc) => bloc.dispose(),
      child: Builder(
        builder: (context) {
          var bloc = BlocProvider.of<GroceryBloc>(context);
          
          return Dialog(
            child: SizedBox(
              width: Provider.of<Constants>(context).groceryDialogSize.width,
              height: Provider.of<Constants>(context).groceryDialogSize.height,
              child: StreamBuilder(
                stream: bloc.outState,
                builder: (context, snapshot) {
                  var state = snapshot.data;
                  if (state is GrocLoadingState) {
                    return const Center(child: CircularProgressIndicator(),);
                  } else if (state is GrocLoadedState || state is GrocEditState) {
                    // var groc = state.grocery;
                    return Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        children: [
                          buildText(context, state, bloc),
                          buildTable(context, bloc),
                          buildCount(context, state, bloc),
                          buildButtons(context, state, bloc),
                        ]
                      )
                    );
                  } 
                  return Container();
                },
              ),
            ),
          );
        }
      )
    );
  }


  // в еdit state - edit, в loaded - text
  Widget buildText(BuildContext context, dynamic state, GroceryBloc bloc) {
    if (state is GrocLoadedState) {
      return Row(
        children: [
          Expanded(
            flex: 3,
            child: Center(
              child: Text(state.grocery.grocName)
            ),
          ),
          Expanded(
            child: Center(
              child: Text(state.grocery.grocMeasure)
            ),
          )
        ],
      );
    } else if (state is GrocEditState) {
      return Row(
        children: [
          Expanded(
            flex: 3,
            child: MyTextField(
              controller: TextEditingController(text: state.grocery.grocName),
              onChanged: (newVal) {
                bloc.inEvent.add(GrocNameChanged(newVal));
              },
            ),
          ),
          Expanded(
            child: GramLiterDropdown(
              value: state.grocery.grocMeasure,
              onChanged: (newVal) {
                bloc.inEvent.add(GrocMeasureChanged(newVal!));
              },
            )
          )
        ],
      );
    } return const Text("something wrong");
  }


  // везде одна и та же
  Widget buildTable(BuildContext context, GroceryBloc bloc) {
    return Expanded(
      child: DataTable(
        columns: const [
          DataColumn(label: Text("постачальник")),
          DataColumn(label: Text("ціна"), numeric: true)
        ],
        rows: [
          for (int i = 0; i < bloc.grocery.suppliedBy.length; i++) DataRow(
            cells: [
              DataCell(Text(bloc.grocery.suppliedBy[i].supplierName)),
              DataCell(Text(bloc.grocery.suppliedBy[i].supGrocPrice.toString()))
            ]
          )
        ],
      ),
    );
  }

  Widget buildCount(BuildContext context, dynamic state, GroceryBloc bloc) {
    return Center(
      child: Row(
        children: [
          const Expanded(
            child: Text("Залишилося: ")
          ),
          Expanded(
            child: Builder(
              builder: (context) {
                if (state is GrocLoadedState) {
                  return Center(child: Text(state.grocery.avaCount.toString()));
                } else if (state is GrocEditState) {
                  return MyTextField(
                    controller: TextEditingController(text: state.grocery.avaCount.toString()),
                    onChanged: (newVal) {
                      // сделать отклик на изменение количества
                      // потом наконец сделать сохранение
                      bloc.inEvent.add(GrocCountChanged(newVal));
                    },
                  );
                } return const Text("something wrong");
              },
            )
          )
        ],
      )
    );
  }


  Widget buildButtons(BuildContext context, dynamic state, GroceryBloc bloc) {
    return Row(
      children: [
        (state is GrocLoadedState) ? ElevatedButton(
          child: const Icon(Icons.edit),
          onPressed: () {
            bloc.inEvent.add(GrocEditEvent());
          },
        ) : ElevatedButton(
          child: const Icon(Icons.save),
          onPressed: () {
            bloc.inEvent.add(GrocSaveEvent());
          }
        ),
        const Spacer(),
        ElevatedButton(
          child: const Text("OK"),
          onPressed: () {
            if (state is GrocLoadedState) Navigator.pop(context);
            
          },
        )
      ],
    );
  }

}