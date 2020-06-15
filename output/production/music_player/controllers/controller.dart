import 'package:flutter/material.dart';
import 'package:mobx/mobx.dart';
part 'controller.g.dart';

class Controller = _ControllerBase with _$Controller;

abstract class _ControllerBase with Store{

  final pageController = PageController(initialPage: 1);

  @observable
  int currentIndex = 1;

  @observable
  bool participacoes = false;

  @action
  changeParticipacoes(bool value) => participacoes = value;

  @action
  changeIndex(int newIndex) => currentIndex = newIndex;

}