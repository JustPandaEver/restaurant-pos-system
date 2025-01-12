import 'package:client/l10nn/app_localizations.dart';
import 'package:client/widgets/navigation_drawer.dart';
import 'package:flutter/material.dart';
import 'package:client/store/widgets/groceries_card.dart';
import 'package:provider/provider.dart';

import '../bloc_provider.dart';
import '../services/repo.dart';

import 'store_bloc.dart';

import 'widgets/suppliers_card.dart';
import 'widgets/buttons_card.dart';

class StorePage extends StatefulWidget {
  const StorePage({Key? key}) : super(key: key);

  @override
  State<StorePage> createState() => _StorePageState();
}

class _StorePageState extends State<StorePage> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider<StoreBloc>(
      // bloc: StoreBloc(Provider.of<Repo>(context)),
      blocBuilder: () => StoreBloc(Provider.of<Repo>(context)),
      blocDispose: (StoreBloc bloc) => bloc.dispose(),
      child: Scaffold(
        drawer: const MyNavigationDrawer(),
        appBar: AppBar(
          title: Center(child: Text(AppLocalizations.of(context)!.store))
        ),
        body: Container(
          padding: const EdgeInsets.all(8),
          child: const Row(
            children: [
              Expanded(child: SuppliersCard()),
              SizedBox(width: 3),
              ButtonsCard(),
              SizedBox(width: 3,),
              Expanded(child: GroceriesCard())
            ],
          )
        ),
      )
    );
  }
}
