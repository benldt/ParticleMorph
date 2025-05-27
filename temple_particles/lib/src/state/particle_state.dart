import 'package:flutter/material.dart';

/// State model for morphing animation progress and status
class MorphState extends ChangeNotifier {
  double t = 0;         // 0-1 progress
  bool   busy = false;
  int    shape = 0;     // Target shape during morphing: 0 sphere | 1 cube | 2 pyramid
  int    currentShape = 0; // Current shape when not morphing
  
  void set(double v){ t=v; notifyListeners(); }
  void begin(int next){ busy=true; shape=next; notifyListeners(); }
  void end(){ busy=false; t=0; currentShape=shape; notifyListeners(); }
}

/// State model for loading progress and status messages
class LoadState extends ChangeNotifier{
  double p=0; 
  String s="Booting…";
  
  void upd(double v,String msg){ p=v; s=msg; notifyListeners(); }
} 