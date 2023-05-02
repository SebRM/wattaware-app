import 'package:flutter/material.dart';

import 'auth_model.dart';

class IndstillingerPage extends StatefulWidget {
  final AuthModel authModel;

  const IndstillingerPage({Key? key, required this.authModel}) : super(key: key);

  @override
  State<IndstillingerPage> createState() => _IndstillingerPageState();
}

class _IndstillingerPageState extends State<IndstillingerPage> {
  String? _selectedEludbyder;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Indstillinger"),
        backgroundColor: const Color(0xff0f4472),
      ),
      body: ListView(
        children: [
          ListTile(
            title: Text("Logget ind som ${widget.authModel.username}"),
          ),
          FutureBuilder<String>(
            future: widget.authModel.getEludbyder(),
            builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
              if (snapshot.hasData) {
                _selectedEludbyder = snapshot.data;
              }
              return ListTile(
                title: const Text("Vælg eludbyder"),
                trailing: snapshot.hasData
                    ? DropdownButton<String>(
                        value: _selectedEludbyder,
                        icon: const Icon(Icons.arrow_downward),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedEludbyder = newValue;
                            widget.authModel.setEludbyder(newValue!);
                          });
                        },
                        items: const [
                          DropdownMenuItem<String>(
                            value: "andelenergiØst",
                            child: Text("Andelenergi Øst"),
                          ),
                          DropdownMenuItem<String>(
                            value: "andelenergiVest",
                            child: Text("Andelenergi Vest"),
                          ),
                        ],
                      )
                    : CircularProgressIndicator(),
              );
            },
          ),
          ListTile(
            title: const Text(
              "Log ud",
              style: TextStyle(color: Colors.red),
            ),
            onTap: widget.authModel.logOut,
            trailing: const Icon(Icons.logout),
            tileColor: Colors.red.shade100,
          ),
        ],
      ),
    );
  }
}
