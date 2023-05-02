import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

import 'auth_model.dart';
import 'page_design.dart';

// This file contains everything used in the elpriser page
class ElpriserPage extends StatelessWidget {
  const ElpriserPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const PageDesign(child: LiveElpriserDisplay());
  }
}

// This stateful widget contains everything to display the live elpriser,
// including the current elpris and the future elpriser in the bar chart.
class LiveElpriserDisplay extends StatefulWidget {
  const LiveElpriserDisplay({super.key});

  @override
  State<LiveElpriserDisplay> createState() => _LiveElpriserDisplayState();
}

class _LiveElpriserDisplayState extends State<LiveElpriserDisplay> {
  // Widget state, elpriser Map used to store the elpriser grabbed from the server.
  Map<String, dynamic> elpriser = {
    "timestamps": [],
    "prices": [],
  };

  // Widget state, calculated on fetch from the elpriser Map,
  // used to calculate the width of the bars in the bar chart.
  double minElpris = 0.00;
  double maxElpris = 5.00;

  // Widget state, used to show loading indicator while fetching data.
  bool isLoading = true;

  // Function to fetch elpriser from the server and store in the elpriser Map.
  Future<void> fetchData() async {
    // Access the AuthModel instance from the context
    AuthModel authModel = Provider.of<AuthModel>(context, listen: false);

    // Await the getEludbyder method and store its result in a variable
    String eludbyder = await authModel.getEludbyder();

    final res = await http.get(Uri.parse('http://${authModel.ip}:8080/elpriser/$eludbyder'));
    if (res.statusCode == 200) {
      setState(() {
        elpriser = json.decode(res.body);
        minElpris = elpriser["prices"]!.reduce((a, b) => a < b ? a : b);
        maxElpris = elpriser["prices"]!.reduce((a, b) => a > b ? a : b);
        isLoading = false;
      });
    } else {
      throw Exception("Failed to load data");
    }
  }

  // Runs when the widget mounts, immediatly fetching data from server.
  @override
  void initState() {
    super.initState();
    fetchData();
  }

  // Generates UI
  @override
  Widget build(BuildContext context) {
    // Show progess indicator while data is being fetched.
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    // Generates the UI
    return Column(
      children: [
        // Big text current elpris.
        Text(elpriser["prices"]![0].toString().padRight(4, '0'), style: const TextStyle(fontSize: 100)),
        Transform.translate(
          offset: const Offset(0, -15),
          child: const Text("kr. / kWh", style: TextStyle(fontSize: 30)),
        ),
        // Bar chart
        Expanded(
          // RefreshIndicator with onRefresh makes it fetch data from
          // the server and reload when you pull down from the top.
          child: RefreshIndicator(
            onRefresh: fetchData,
            child: ListView.builder(
              itemCount: elpriser["prices"]!.length,
              itemBuilder: (context, index) {
                // Calculate the width of each bar in the chat:
                // (pris - min) / (max - min) * 310 px + 50 px.
                final barWidth = (elpriser["prices"]![index] - minElpris) / (maxElpris - minElpris) * 310 + 50;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3.0),
                  child: Row(children: [
                    Container(
                      width: barWidth,
                      height: 25,
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.only(left: 5),
                      decoration: const BoxDecoration(
                        color: Color(0xff06346d),
                        borderRadius: BorderRadius.only(
                          bottomRight: Radius.circular(10),
                          topRight: Radius.circular(10),
                        ),
                      ),
                      // Adds the timestamp to the left.
                      child: Text(
                        DateTime.parse(elpriser["timestamps"]![index]).hour.toString().padLeft(2, '0'),
                        style: const TextStyle(fontSize: 13, color: Colors.white),
                      ),
                    ),
                    // Contains the elpris label to the right of the bar.
                    Container(
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.only(left: 3),
                      child: Text(
                        elpriser["prices"]![index].toStringAsFixed(2),
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ]),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
