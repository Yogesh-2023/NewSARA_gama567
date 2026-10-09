import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import '../ulits/Constents.dart';

class ChartTableScreen extends StatefulWidget {
  final int gameId;
  final String gameType;
  final String gameName;

  const ChartTableScreen({
    super.key,
    required this.gameId,
    required this.gameType,
    required this.gameName,
  });

  @override
  State<ChartTableScreen> createState() => _ChartTableScreenState();
}

class _ChartTableScreenState extends State<ChartTableScreen> {
  List<dynamic> chartData = [];
  bool isLoading = true;
  bool hasError = false;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchChartData();
  }

  Future<void> fetchChartData() async {
    final box = GetStorage();

    final String? token = box.read("accessToken");
    final String? registerId = box.read("registerId");
    final String? deviceId = box.read("deviceId");
    final String? deviceName = box.read("deviceName");

    // 🔥 Print EVERYTHING for Debugging
    print("\n=============== CHART TABLE DEBUG START ===============");
    print("API URL               : ${Constant.apiEndpoint}table-chart");
    print("Token                 : $token");
    print("Register ID           : $registerId");
    print("Device ID             : $deviceId");
    print("Device Name           : $deviceName");
    print("Sending Game ID       : ${widget.gameId}");
    print("Sending Game Type     : ${widget.gameType}");
    print("=======================================================\n");

    if (token == null || token.isEmpty) {
      setState(() {
        isLoading = false;
        hasError = true;
        errorMessage = "Missing token. Please login again.";
      });
      print("❌ ERROR: ACCESS TOKEN MISSING");
      return;
    }

    try {
      print("📡 Sending POST Request...");

      final response = await http.post(
        Uri.parse('${Constant.apiEndpoint}table-chart'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'accessStatus': '1',
          'deviceId': deviceId ?? "",
          'deviceName': deviceName ?? "",
          'registerId': registerId ?? "",
        },
        body: jsonEncode({
          'gameId': widget.gameId,
          'gameType': widget.gameType,
        }),
      );

      print("📥 Response Received!");
      print("STATUS CODE : ${response.statusCode}");
      print("RAW BODY    : ${response.body}");

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);

        // Validate JSON
        if (json['status'] == true && json['info'] is List) {
          setState(() {
            chartData = json['info'];
            isLoading = false;
            hasError = false;
          });

          print("✔ SUCCESS: Loaded ${chartData.length} chart rows.");
        } else {
          print("❌ ERROR FROM SERVER: ${json['msg']}");
          setState(() {
            isLoading = false;
            hasError = true;
            errorMessage = json['msg'] ?? "Invalid response from server.";
          });
        }
      } else {
        print("❌ SERVER STATUS FAILURE = ${response.statusCode}");
        setState(() {
          isLoading = false;
          hasError = true;
          errorMessage = "Server Error: ${response.statusCode}";
        });
      }
    } catch (e) {
      print("❌ EXCEPTION: $e");
      setState(() {
        isLoading = false;
        hasError = true;
        errorMessage = "Network error. Please try again.";
      });
    }

    print("=============== CHART TABLE DEBUG END =================\n");
  }

  Widget buildHeaderRow() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Row(
        children: [
          Expanded(
            child: Center(
              child: Text(
                'Date',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16,color: Colors.black),
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                'Open',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16,color: Colors.black),
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                'Jodi',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16,color: Colors.black),
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                'Close',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16,color: Colors.black),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildDataRow(Map<String, dynamic> row) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 3)],
      ),
      child: Row(
        children: [
          Expanded(
            child: Center(
              child: Text(
                row['date'] ?? '',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                row['open'] ?? '',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                row['digit'] ?? '',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                row['close'] ?? '',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(widget.gameName.isEmpty ? 'Charts' : widget.gameName,style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold),),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SafeArea(
        child: Container(
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: isLoading
                ? const Center(
              child: CircularProgressIndicator(color: Colors.amber),
            )
                : hasError
                ? Center(
              child: Text(
                errorMessage,
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold),
              ),
            )
                : chartData.isEmpty
                ? const Center(
              child: Text(
                'No chart data found.',
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold),
              ),
            )
                : Column(
              children: [
                buildHeaderRow(),
                const SizedBox(height: 12),
                Expanded(
                  child: ListView.builder(
                    itemCount: chartData.length,
                    itemBuilder: (context, index) {
                      return buildDataRow(chartData[index]);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
