import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';

class DebugBlocObserver extends BlocObserver {
  
  @override
  void onCreate(BlocBase bloc) {
    super.onCreate(bloc);
    debugPrint("[Create Bloc] $bloc");
  }
  @override
  void onEvent(Bloc bloc, Object? event) {
    super.onEvent(bloc, event);
    debugPrint("[Event] $event");
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    super.onError(bloc, error, stackTrace);
  }

  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    debugPrint("[Transition] ${bloc.runtimeType} from: ${transition.currentState} to: ${transition.nextState} ");
    super.onTransition(bloc, transition);
  }
}