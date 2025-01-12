import 'package:client/bloc_provider.dart';
import 'package:client/employees/employees_bloc.dart';
import 'package:client/employees/employees_states_events.dart';
import 'package:client/employees/widgets/diary_add_dialog.dart';
import 'package:client/employees/widgets/diary_container.dart';
import 'package:client/employees/widgets/employee_container.dart';
import 'package:client/employees/widgets/employee_edit_dialog.dart';
import 'package:client/employees/widgets/role_edit_dialog.dart';
import 'package:client/employees/widgets/role_container.dart';
import 'package:client/l10nn/app_localizations.dart';
import 'package:client/services/models.dart';
import 'package:client/widgets/navigation_drawer.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/repo.dart';
import 'filter_sort_employee/filter_sort_employee.dart';

class Employees extends StatefulWidget {
  const Employees({Key? key}) : super(key: key);

  @override
  State<Employees> createState() => _EmployeesState();
}

enum EmployeesPage { employees, roles }

class _EmployeesState extends State<Employees> {

  EmployeesPage curPage = EmployeesPage.employees;
  int curI = 0;
  GlobalKey<ScaffoldState> gc0 = GlobalKey<ScaffoldState>();
  late AppLocalizations l;

  @override
  Widget build(BuildContext context) {
    l = AppLocalizations.of(context)!;
    return BlocProvider<EmployeeBloc>(
      blocBuilder: () => EmployeeBloc(Provider.of<Repo>(context, listen: false)),
      blocDispose: (EmployeeBloc bloc) => bloc.dispose(),
      child: Builder(
        builder: (context) {
          var bloc = BlocProvider.of<EmployeeBloc>(context);
          return StreamBuilder(
            stream: bloc.outState,
            builder: (context, snapshot) {
              var state = snapshot.data;
              if (state is EmployeeLoadingState) {
                return Scaffold(bottomNavigationBar: buildBNBar(),appBar: AppBar(leading: const BackButton()), body: const Center(child: CircularProgressIndicator()));
              }
              
              if (curI == 0) {
                if (state is EmployeeLoadedState) {
                  return Scaffold(
                    key: gc0,
                    drawer: const MyNavigationDrawer(),
                    endDrawer: const FilterSortEmployee(),
                    bottomNavigationBar: buildBNBar(),
                    appBar: buildAppBar(bloc), 
                    body: ListView(
                      children: [
                        for (int i = 0; i < bloc.employees.length; i++) if (bloc.filteredEmployees.contains(bloc.employees[i])) EmployeeContainer(
                          employee: bloc.employees[i],
                          role: bloc.roles.firstWhere((e) => e.roleId == bloc.employees[i].roleId),
                          onTap: () async {
                            await showDialog(
                              context: context,
                              builder: (context) {
                                return EmployeeEditDialog(
                                  roles: bloc.roles,
                                  employee: bloc.employees[i],
                                  actions: [
                                    ElevatedButton(
                                      child: Text(l.save),
                                      onPressed: () async {
                                        if (bloc.roles[i].saveable) {
                                          await Provider.of<Repo>(context, listen: false).updateEmployee(bloc.employees[i]);
                                          Navigator.pop(context);
                                        } 
                                      },
                                    ),
                                  ]
                                );
                              }
                            );
                            bloc.inEvent.add(EmployeeLoadEvent());
                          },
                        )
                      ]
                    )
                  );
                }

              } else if (curI == 1) {
                if (state is EmployeeLoadedState) {
                  return Scaffold(
                    appBar: buildAppBar(bloc),
                    body: ListView(
                      children: [
                        for (int i = 0; i < bloc.roles.length; i++) RoleContainer(
                          bloc.roles[i],
                          onTap: () async {
                            // диалог для просмотра / редактирования роли
                            await showDialog(
                              context: context, 
                              builder: (_) => RoleEditDialog(
                                title: Center(child: Text(l.update_role)),
                                role: bloc.roles[i],
                                actions: [
                                  ElevatedButton(
                                    child: Text(l.delete),
                                    onPressed: () async {
                                      await Provider.of<Repo>(context, listen: false).deleteRole(bloc.roles[i].roleId!);
                                      Navigator.pop(context);
                                    },
                                  ),
                                  ElevatedButton(
                                    child: Text(l.save),
                                    onPressed: () async {
                                      if (bloc.roles[i].saveable) {
                                        await Provider.of<Repo>(context, listen: false).updateRole(bloc.roles[i]);
                                        Navigator.pop(context);
                                      } 
                                    },
                                  ),
                                ],
                              )
                            );
                            bloc.inEvent.add(EmployeeLoadEvent());
                          },
                        )
                      ]
                    ),
                    bottomNavigationBar: buildBNBar(),
                  );
                }
              } else if (curI == 2) {
                return Scaffold(
                  appBar: buildAppBar(bloc),
                  bottomNavigationBar: buildBNBar(),
                  body: ListView(
                    children: [
                      for (int i = 0; i < bloc.diary.length; i++) DiaryContainer(
                        diary: bloc.diary[i], 
                        onDelete: () async {
                          await Provider.of<Repo>(context, listen: false).deleteDiary(bloc.diary[i].dId);
                          bloc.inEvent.add(EmployeeReloadDiary());
                        },
                        onGone: () async {
                          await Provider.of<Repo>(context, listen: false).diaryGone(bloc.diary[i].empId);
                          bloc.inEvent.add(EmployeeReloadDiary());
                        }
                      )
                    ],
                  ),
                );
              }
              return Container();
            }
          );
        }
      ),
    );
  }

  PreferredSizeWidget buildAppBar(EmployeeBloc bloc) {
    Role role = Role.init();
    Employee emp = Employee.init();
    return AppBar(
      title: Center(child: curI == 0 ? Text(l.employees) : curI == 1 ? Text(l.roles) : Text(l.diary)), 
      actions: [
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: () async {
            await showDialog(
              context: context, 
              builder: (context) {
                if (curI == 0) {
                  return EmployeeEditDialog(
                    roles: bloc.roles, 
                    employee: emp,
                    actions: [
                      ElevatedButton(
                        child: Text(l.save),
                        onPressed: () async {
                          if (emp.saveable) {
                            await Provider.of<Repo>(context, listen: false).addEmployee(emp);
                            Navigator.pop(context); 
                          }
                        },
                      )
                    ],
                  );
                } else if (curI == 1) {
                  return RoleEditDialog(
                    title: Center(child: Text(l.add_role)),
                    role: role,
                    actions: [
                      ElevatedButton(
                        child: Text(l.add),
                        onPressed: () async {
                          if (role.saveable) {
                            await Provider.of<Repo>(context, listen: false).addRole(role);
                            Navigator.pop(context); 
                          }
                        },
                      )
                    ],
                  );
                } else if (curI == 2) {
                  return DiaryAddDialog(employees: bloc.employees);
                }
                return const Dialog(child: Center(child: Text("something went wrong")));
              }
            );
            bloc.inEvent.add(EmployeeLoadEvent());
          }
        ),
        if (curI == 0) IconButton(
          icon: const Icon(Icons.filter_alt_outlined),
          onPressed: () {
            gc0.currentState?.openEndDrawer();
          },
        )
      ]
    );
  }

  Widget buildBNBar() {
    return BottomNavigationBar(
      currentIndex: curI,
      items: [
        BottomNavigationBarItem(icon: const Icon(Icons.people_alt_rounded), label: l.employees, tooltip: ''),
        BottomNavigationBarItem(icon: const Icon(Icons.content_paste_search_rounded), label: l.roles, tooltip: ''),
        BottomNavigationBarItem(icon: const Icon(Icons.note_rounded), label: l.diary, tooltip: '')
      ],
      onTap: (i) {
        setState(() {
          curI = i;
        });
      },
    );
  }
}
