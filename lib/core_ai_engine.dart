import 'package:flutter/material.dart';

class CoreAIEngine {
  final List<String> logs = [];
  final List<String> alerts = [];

  void receiveCommand(String command) {
    logs.add("[User] $command");
    String response = _processCommand(command);
    logs.add("[Core AI] $response");
  }

  String _processCommand(String command) {
    final lower = command.toLowerCase();

    if (lower.contains("create") && lower.contains("login")) {
      return "Starting login screen build. Estimated time: 3 minutes.";
    } else if (lower.contains("create") && lower.contains("signup")) {
      return "Preparing signup system. Allocating AI Designer.";
    } else if (lower.contains("error") || lower.contains("issue")) {
      alerts.add("⚠️ Critical issue detected: '$command'");
      return "Issue logged and escalated to High Alert Panel.";
    } else if (lower.contains("build everything")) {
      return "Deploying all modules. This will take 10–15 minutes depending on complexity.";
    }

    return "Command received. Analyzing and preparing execution.";
  }

  List<String> getLogs() => logs;

  List<String> getAlerts() => alerts;
}
