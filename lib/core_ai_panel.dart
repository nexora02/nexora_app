import 'package:flutter/material.dart';
import 'core_gpt_handler.dart';
import 'core_file_writer.dart';

class CoreAIPanel extends StatefulWidget {
  const CoreAIPanel({super.key});

  @override
  State<CoreAIPanel> createState() => _CoreAIPanelState();
}

class _CoreAIPanelState extends State<CoreAIPanel> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> chatLog = [];
  final List<String> systemLog = [];
  final List<String> alerts = [];
  final TextEditingController _chatController = TextEditingController();

  // Tracker Data
  int percentageComplete = 0;
  int tokenUsed = 0;
  double estimatedCost = 0.0;
  List<String> taskQueue = [];
  String currentTask = "Idle";

  late DateTime taskStartTime;
  String frozenTopStatus = "🧠 Idle";

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    taskStartTime = DateTime.now();
    systemLog.add("🧠 AI System booted.");
    systemLog.add("🔎 Awaiting user input...");
  }

  String _extractFileName(String command) {
    final parts = command.toLowerCase().split(" ");
    for (final part in parts) {
      if (part.contains("screen")) return "${part}_screen.dart";
    }
    return "generated_ai_output.dart";
  }

  Future<void> _sendCommand() async {
    final text = _chatController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      chatLog.add("🧍 You: $text");
      systemLog.add("💡 AI parsing input...");
      systemLog.add("⚙️ Analyzing: \"$text\"");
      chatLog.add("🤖 AI: Working on \"$text\" now...");
      taskStartTime = DateTime.now();
      currentTask = text;
      frozenTopStatus = "⚙️ Building: $text";
      percentageComplete = 0;
    });

    _chatController.clear();

    try {
      final response = await CoreGPTHelper.sendCommandToGPT(text);

      final filename = _extractFileName(text);
      final saveResult = await CoreFileWriter.saveDartFile(filename, response);

      setState(() {
        chatLog.add("🤖 AI: $response");
        systemLog.add("✅ AI response received");
        systemLog.add(saveResult);
        currentTask = filename;
        percentageComplete = 100;
        tokenUsed += 400; // Example token count
        estimatedCost += 0.004; // Example cost
        taskQueue.add(filename);
        frozenTopStatus = "✅ Built: $filename";
      });
    } catch (e) {
      setState(() {
        alerts.add("❌ Error: $e");
        systemLog.add("❗ GPT failed to respond.");
        frozenTopStatus = "❌ Error occurred";
      });
    }
  }

  Widget _buildChatTab() {
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(12),
            children: chatLog.map((msg) => _buildMessage(msg)).toList(),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(12),
          color: Colors.grey[900],
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _chatController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    hintText: "Ask AI something...",
                    hintStyle: TextStyle(color: Colors.grey),
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _sendCommand,
                child: const Text("Send"),
              )
            ],
          ),
        )
      ],
    );
  }

  Widget _buildLogsTab() {
    final duration = DateTime.now().difference(taskStartTime);
    return Column(
      children: [
        Container(
          color: Colors.grey[850],
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("⏱ Time: ${duration.inSeconds}s", style: const TextStyle(color: Colors.greenAccent)),
              Text("⚙️ Task: $currentTask", style: const TextStyle(color: Colors.lightBlueAccent)),
              Text("✅ Done: ${taskQueue.length}", style: const TextStyle(color: Colors.orangeAccent)),
            ],
          ),
        ),
        const Divider(height: 1, color: Colors.grey),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(12),
            children: [
              ...systemLog.map((msg) => _buildLog(msg)),
              const SizedBox(height: 20),
              const Divider(color: Colors.teal),
              const Text("📊 Tracker", style: TextStyle(color: Colors.tealAccent, fontSize: 18)),
              Text("📈 Progress: $percentageComplete%", style: const TextStyle(color: Colors.white)),
              Text("🧠 Tokens Used: $tokenUsed", style: const TextStyle(color: Colors.white)),
              Text("💰 Estimated Cost: £${estimatedCost.toStringAsFixed(4)}", style: const TextStyle(color: Colors.white)),
              Text("📋 Current Task: $currentTask", style: const TextStyle(color: Colors.white)),
              Text("📦 Queue: ${taskQueue.join(", ")}", style: const TextStyle(color: Colors.white)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAlertsTab() {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: alerts.isEmpty
          ? [const Text("✅ No critical alerts", style: TextStyle(color: Colors.greenAccent))]
          : alerts.map((msg) => _buildAlert(msg)).toList(),
    );
  }

  Widget _buildMessage(String msg) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Text(msg, style: const TextStyle(color: Colors.white)),
      );

  Widget _buildLog(String msg) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Text("📄 $msg", style: const TextStyle(color: Colors.amber)),
      );

  Widget _buildAlert(String msg) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Text("🚨 $msg", style: const TextStyle(color: Colors.redAccent)),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.grey[900],
        title: const Text("🧠 Core AI Manager"),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: "Chat"),
            Tab(text: "Logs"),
            Tab(text: "Alerts"),
            Tab(text: "Tracker"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildChatTab(),
          _buildLogsTab(),
          _buildAlertsTab(),
          _buildLogsTab(), // Tracker is part of Logs tab visuals
        ],
      ),
    );
  }
}
