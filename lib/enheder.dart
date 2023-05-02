import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'auth_model.dart';

import 'enheder_model.dart';
import 'page_design.dart';
import 'enhed.dart';

class EnhederPage extends StatelessWidget {
  const EnhederPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthModel>(context, listen: false);
    return PageDesign(
      child: ChangeNotifierProvider(
        create: (context) => EnhederModel(auth: auth),
        child: const EnhederUI(),
      ),
    );
  }
}

class EnhederUI extends StatelessWidget {
  const EnhederUI({super.key});

  @override
  Widget build(BuildContext context) {
    final enhederModel = Provider.of<EnhederModel>(context);

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Transform.translate(
          offset: const Offset(0, 18),
          child: const Padding(
            padding: EdgeInsets.only(left: 10.0),
            child: Text(
              "Mine enheder",
              style: TextStyle(
                fontSize: 20,
              ),
            ),
          ),
        ),
        Expanded(
          child: Container(
            margin: const EdgeInsets.only(left: 3, right: 3),
            child: ValueListenableBuilder(
              valueListenable: enhederModel.isInitialized,
              builder: ((context, isInitialized, _) {
                if (isInitialized) {
                  return ChangeNotifierProvider.value(
                    value: enhederModel,
                    child: Consumer<EnhederModel>(
                      builder: (context, model, child) {
                        return GridView.builder(
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 0,
                            mainAxisSpacing: 0,
                          ),
                          itemCount: model.devices.length + 1,
                          itemBuilder: (context, index) {
                            if (index == model.devices.length) {
                              // Render the add device button
                              return InkWell(
                                onTap: () {
                                  // Handle add device logic here
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: const Color(0xff0f4472), width: 4),
                                    color: Colors.white,
                                  ),
                                  margin: const EdgeInsets.all(6),
                                  padding: const EdgeInsets.all(6),
                                  child: const Center(
                                    child: Icon(
                                      Icons.add,
                                      size: 64,
                                    ),
                                  ),
                                ),
                              );
                            } else {
                              // Render the device item
                              Device? device = model.devices[index];
                              return InkWell(
                                onTap: () async {
                                  // Navigate to the separate screen
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) {
                                      return Enhed(index: index, enhederModel: model);
                                    }),
                                  );
                                  model.isInitialized.value = false;
                                  await model.fetchDevices();
                                  model.isInitialized.value = true;
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: const Color(0xff0f4472), width: 4),
                                    color: Colors.white,
                                  ),
                                  margin: const EdgeInsets.all(6),
                                  padding: const EdgeInsets.all(6),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          Icon(
                                            device.status == 'connected' ? Icons.wifi : Icons.wifi_off,
                                            color: device.status == 'connected' ? Colors.green : Colors.red,
                                          ),
                                          const SizedBox(width: 4),
                                          Icon(
                                            Icons.power_settings_new,
                                            color: device.isOn ? Colors.green : Colors.red,
                                          ),
                                        ],
                                      ),
                                      Expanded(
                                        child: Center(
                                          child: Icon(
                                            IconData(device.icon, fontFamily: 'MaterialIcons'),
                                            size: 64,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        device.name,
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }
                          },
                        );
                      },
                    ),
                  );
                } else {
                  return const Center(
                    child: SizedBox(
                      width: 50,
                      height: 50,
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
              }),
            ),
          ),
        ),
      ],
    );
  }
}
