import 'package:deep_work/bloc/ToDo/to_do_bloc.dart';
import 'package:deep_work/repo/firestore_repo.dart';
import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

class TodoList extends StatelessWidget {
  TodoList();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          ToDoBloc(RepositoryProvider.of<FirestoreRepo>(context))
            ..add(ToDoInit()),
      child: BlocBuilder<ToDoBloc, ToDoState>(
        builder: (context, state) {
          if (state is ToDoInitial) {
            return Center(child: CircularProgressIndicator());
          } else if (state is ToDoLoaded) {
            return ListView.builder(
              itemCount: state.goals.length,
              itemBuilder: (context, index) {
                return ExpansionTile(
                  initiallyExpanded: false,
                  title: Text(
                    state.goals[index].name,
                  ),
                  children: [
                    SizedBox(
                      height: 150,
                      child: SingleChildScrollView(
                        physics: ScrollPhysics(),
                        controller: ScrollController(),
                        child: ListView.builder(
                          shrinkWrap: true,
                          primary: false,
                          scrollDirection: Axis.vertical,
                          padding: EdgeInsets.all(8.0),
                          itemCount: state.goals[index].tasks.length,
                          itemBuilder: (context, taskIndex) {
                            return ListTile(
                              title: Text(
                                state.goals[index].tasks[taskIndex].name,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    // Add more widgets here if needed
                  ],
                );
              },
            );
          } else {
            return Center(child: Text('error loading goals'));
          }
        },
      ),
    );
  }
}
