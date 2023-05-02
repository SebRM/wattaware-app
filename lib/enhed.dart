import 'dart:convert';

import 'package:flutter/material.dart';

import 'enheder_model.dart';
import 'schedule.dart';

class Enhed extends StatefulWidget {
  final int index;
  final EnhederModel enhederModel;
  const Enhed({Key? key, required this.index, required this.enhederModel}) : super(key: key);

  @override
  State<Enhed> createState() => _EnhedState();
}

class _EnhedState extends State<Enhed> {
  late TextEditingController _nameController;
  late Schedule _schedule;
  int? _usageHours;
  int? _usageMinutes;

  @override
  void initState() {
    super.initState();
    widget.enhederModel.addListener(_update);
    _nameController = TextEditingController(text: widget.enhederModel.devices[widget.index].name);
    _schedule = Schedule.fromJson(jsonDecode(widget.enhederModel.devices[widget.index].schedule) as Map<String, dynamic>);
    _usageHours = null;
    _usageMinutes = null;
  }

  @override
  void dispose() {
    _nameController.dispose();
    widget.enhederModel.removeListener(_update);
    super.dispose();
  }

  void _update() {
    setState(() {});
  }

  void _updateName(String newName) {
    setState(() {
      widget.enhederModel.devices[widget.index].name = newName;
    });
    widget.enhederModel.updateInfo(
      widget.enhederModel.devices[widget.index].uuid,
      name: newName,
    );
  }

  void _updateIcon(int iconCodePoint) {
    setState(() {
      widget.enhederModel.devices[widget.index].icon = iconCodePoint;
    });
    widget.enhederModel.updateInfo(
      widget.enhederModel.devices[widget.index].uuid,
      codePoint: iconCodePoint,
    );
  }

  Future<void> _showIconPickerDialog() async {
    int? selectedIconCodePoint = await showDialog<int>(
      context: context,
      builder: (BuildContext context) {
        const int crossAxisCount = 5; // Change this value to control grid columns
        const double iconSize = 32; // Change this value to adjust icon size

        return Dialog(
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              final double dialogWidth = constraints.maxWidth;
              final double dialogHeight = dialogWidth;

              // ignore: sized_box_for_whitespace
              return Container(
                height: dialogHeight,
                child: GridView.count(
                  crossAxisCount: crossAxisCount,
                  childAspectRatio: 1,
                  mainAxisSpacing: 2,
                  crossAxisSpacing: 2,
                  padding: const EdgeInsets.all(2),
                  children: _iconList.map((iconCodePoint) {
                    return IconButton(
                      icon: Icon(IconData(iconCodePoint, fontFamily: 'MaterialIcons')),
                      iconSize: iconSize,
                      onPressed: () {
                        Navigator.pop(context, iconCodePoint);
                      },
                    );
                  }).toList(),
                ),
              );
            },
          ),
        );
      },
    );

    if (selectedIconCodePoint != null) {
      _updateIcon(selectedIconCodePoint);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(widget.enhederModel.devices[widget.index].name),
        backgroundColor: const Color(0xff0f4472),
        actions: [
          Icon(
            widget.enhederModel.devices[widget.index].status == 'connected' ? Icons.wifi : Icons.wifi_off,
            color: widget.enhederModel.devices[widget.index].status == 'connected' ? Colors.green : Colors.red,
          ),
          const SizedBox(width: 8),
          Icon(
            Icons.power_settings_new,
            color: widget.enhederModel.devices[widget.index].isOn ? Colors.green : Colors.red,
          ),
          const SizedBox(width: 12), // Add some space to the right of the icons
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.all(10),
                    ),
                    onChanged: (value) {
                      _updateName(value);
                    },
                  ),
                ),
                const SizedBox(width: 16),
                InkWell(
                  onTap: _showIconPickerDialog,
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Icon(
                      IconData(widget.enhederModel.devices[widget.index].icon, fontFamily: 'MaterialIcons'),
                      size: 30,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(top: 6, bottom: 8),
            child: Text(
              "Indstil planen for enheden",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
              ),
            ),
          ),
          _buildSchedule(),
        ],
      ),
    );
  }

  Widget _buildSchedule() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildScheduleModeButton("manual", Icons.power_settings_new),
            _buildScheduleModeButton("timed", Icons.timer_outlined),
            _buildScheduleModeButton("cap", Icons.attach_money),
            _buildScheduleModeButton("usage", Icons.show_chart),
          ],
        ),
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: _buildScheduleForm(),
        ),
      ],
    );
  }

  Widget _buildScheduleForm() {
    switch (_schedule.mode) {
      case "manual":
        return Center(
          child: Container(
            margin: const EdgeInsets.only(top: 30),
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(200),
              color: (widget.enhederModel.devices[widget.index].isOn) ? Colors.green : Colors.red,
            ),
            child: IconButton(
              onPressed: () {
                setState(() {
                  _schedule.state = !(widget.enhederModel.devices[widget.index].isOn);
                });
                _updateSchedule();
              },
              icon: const Icon(
                Icons.power_settings_new,
                size: 90,
                color: Colors.white,
              ),
            ),
          ),
        );
      case "timed":
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: 48,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Brug en tidsbaseret plan.",
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
            Row(
              children: [
                DropdownButton<bool>(
                  value: _schedule.state,
                  items: const [
                    DropdownMenuItem(
                      value: true,
                      child: Text("Tænd"),
                    ),
                    DropdownMenuItem(
                      value: false,
                      child: Text("Sluk"),
                    ),
                  ],
                  onChanged: (bool? value) {
                    setState(() {
                      _schedule.state = value!;
                    });
                  },
                ),
                const Text(
                  " fra",
                  style: TextStyle(fontSize: 16),
                ),
                TextButton(
                  onPressed: () => _selectTime(context, "start"),
                  child: Text(_schedule.from != null ? _formatTime(_schedule.from) : "fra"),
                ),
                const Text(
                  " til",
                  style: TextStyle(fontSize: 16),
                ),
                TextButton(
                  onPressed: () => _selectTime(context, "end"),
                  child: Text(_schedule.until != null ? _formatTime(_schedule.until) : "til"),
                ),
              ],
            ),
            Row(
              children: [
                const Text(
                  "og gentag ",
                  style: TextStyle(fontSize: 16),
                ),
                DropdownButton<int>(
                  value: _schedule.repeat,
                  items: const [
                    DropdownMenuItem(
                      value: 4102441200,
                      child: Text("aldrig"),
                    ),
                    DropdownMenuItem(
                      value: 3600,
                      child: Text("hver time"),
                    ),
                    DropdownMenuItem(
                      value: 86400,
                      child: Text("hver dag"),
                    ),
                    DropdownMenuItem(
                      value: 604800,
                      child: Text("hver uge"),
                    ),
                  ],
                  onChanged: (int? value) {
                    setState(() {
                      _schedule.repeat = value!;
                    });
                  },
                ),
              ],
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xff165998)),
              onPressed: () {
                _adjustTime();
                _updateSchedule();
              },
              child: const Text(
                "Indstil",
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        );
      case "cap":
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: 48,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Brug en plan baseret på et prisloft.",
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
            Row(
              children: [
                const Text(
                  "Tænd kun når strømmen koster under ",
                  style: TextStyle(fontSize: 16),
                ),
                FloatInputPicker(
                  initialValue: _schedule.cap ?? 1.00,
                  maxVal: 10.0,
                  interval: 0.05,
                  onChanged: (double newValue) {
                    setState(() {
                      _schedule.cap = newValue;
                    });
                  },
                ),
                const Text(
                  " kr. / kWh.",
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
            Row(
              children: [
                const Text(
                  "Bliv ved ",
                  style: TextStyle(fontSize: 16),
                ),
                DropdownButton<bool>(
                  value: _schedule.forever ?? true,
                  items: const [
                    DropdownMenuItem(
                      value: true,
                      child: Text("for evigt"),
                    ),
                    DropdownMenuItem(
                      value: false,
                      child: Text("indtil"),
                    ),
                  ],
                  onChanged: (bool? value) {
                    setState(() {
                      _schedule.forever = value!;
                    });
                  },
                ),
                !(_schedule.forever ?? true)
                    ? Row(
                        children: [
                          TextButton(
                            onPressed: () => _selectDateTime(context),
                            child: Text(_schedule.until != null ? _formatDateTime(_schedule.until) : "indtil"),
                          ),
                          const Text(
                            ",  derefter ",
                            style: TextStyle(fontSize: 16),
                          ),
                          DropdownButton<bool>(
                            value: _schedule.then ?? false,
                            items: const [
                              DropdownMenuItem(
                                value: true,
                                child: Text("tænd"),
                              ),
                              DropdownMenuItem(
                                value: false,
                                child: Text("sluk"),
                              ),
                            ],
                            onChanged: (bool? value) {
                              setState(() {
                                _schedule.then = value!;
                              });
                            },
                          ),
                        ],
                      )
                    : const Text(
                        "",
                        style: TextStyle(fontSize: 16),
                      ),
              ],
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xff165998)),
              onPressed: () {
                _updateSchedule();
              },
              child: const Text(
                "Indstil",
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        );
      case "usage":
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Brug en plan baseret på forbrug af ",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                DropdownButton<String>(
                  value: _schedule.of,
                  items: const [
                    DropdownMenuItem(
                      value: "timer",
                      child: Text("timer"),
                    ),
                    DropdownMenuItem(
                      value: "kr.",
                      child: Text("kr."),
                    ),
                    DropdownMenuItem(
                      value: "kWh",
                      child: Text("kWh"),
                    ),
                  ],
                  onChanged: (String? value) {
                    setState(() {
                      _schedule.of = value;
                    });
                  },
                ),
              ],
            ),
            SizedBox(
              height: 48,
              child: Row(
                children: [
                  const Text(
                    "Brug præcis ",
                    style: TextStyle(fontSize: 16),
                  ),
                  (_schedule.of == "timer")
                      ? Row(
                          children: [
                            IntInputPicker(
                              initialValue: _usageHours ?? 1,
                              minVal: 0,
                              maxVal: 23,
                              interval: 1,
                              onChanged: (int newValue) {
                                setState(() {
                                  _usageHours = newValue * 3600;
                                });
                              },
                            ),
                            const Text(
                              ":",
                              style: TextStyle(fontSize: 16),
                            ),
                            IntInputPicker(
                              initialValue: _usageMinutes ?? 0,
                              minVal: 0,
                              maxVal: 55,
                              interval: 5,
                              onChanged: (int newValue) {
                                setState(() {
                                  _usageHours = newValue * 3600;
                                });
                              },
                            ),
                          ],
                        )
                      : FloatInputPicker(
                          initialValue: _schedule.value ?? 5.0,
                          maxVal: 20.0,
                          interval: 0.1,
                          onChanged: (double newValue) {
                            setState(() {
                              _schedule.value = newValue;
                            });
                          },
                        ),
                  Text(
                    " ${_schedule.of} pr. ",
                    style: const TextStyle(fontSize: 16),
                  ),
                  IntInputPicker(
                    initialValue: ((_schedule.period ?? 1) ~/ 3600),
                    minVal: 1,
                    maxVal: 24,
                    interval: 1,
                    onChanged: (int newValue) {
                      setState(() {
                        _schedule.period = newValue * 3600;
                      });
                    },
                  ),
                  Text(
                    " time${(_schedule.period == 3600) ? '' : 'r'}",
                    style: const TextStyle(fontSize: 16),
                  )
                ],
              ),
            ),
            const SizedBox(
              height: 48,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "når strømmen er billigst.",
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xff165998)),
              onPressed: () {
                if (_schedule.of == "timer") {
                  _schedule.value = (_usageHours! + _usageMinutes! / 60);
                }
                _updateSchedule();
              },
              child: const Text(
                "Indstil",
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        );
      default:
        return const Text("error");
    }
  }

  _buildScheduleModeButton(String mode, IconData iconData) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _schedule.mode = mode;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: (_schedule.mode == mode) ? const Color(0xff165998) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.all(8),
        margin: const EdgeInsets.only(left: 8, right: 8),
        child: Icon(
          iconData,
          color: _schedule.mode == mode ? Colors.white : Colors.black,
        ),
      ),
    );
  }

  _updateSchedule() {
    widget.enhederModel.updateSchedule(
      widget.enhederModel.devices[widget.index].uuid,
      jsonEncode({"schedule": _schedule.toJson()}),
    );
  }

  Future<void> _selectTime(BuildContext context, String type) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      DateTime now = DateTime.now();
      DateTime selectedDateTime = DateTime(now.year, now.month, now.day, picked.hour, picked.minute);
      setState(() {
        if (type == "start") {
          _schedule.from = selectedDateTime.millisecondsSinceEpoch ~/ 1000;
        } else {
          _schedule.until = selectedDateTime.millisecondsSinceEpoch ~/ 1000;
        }
      });
    }
  }

  Future<void> _selectDateTime(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      // ignore: use_build_context_synchronously
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (pickedTime != null) {
        DateTime selectedDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );

        setState(() {
          _schedule.until = selectedDateTime.millisecondsSinceEpoch ~/ 1000;
        });
      }
    }
  }

  void _adjustTime() {
    DateTime from = DateTime.fromMillisecondsSinceEpoch((_schedule.from ?? 0) * 1000);
    DateTime until = DateTime.fromMillisecondsSinceEpoch((_schedule.until ?? 0) * 1000);
    DateTime now = DateTime.now();

    DateTime newFrom = from;
    DateTime newUntil = until;

    if (from.isBefore(now)) {
      newFrom = DateTime(now.year, now.month, now.day + 1, from.hour, from.minute);
      newUntil = DateTime(now.year, now.month, now.day + 1, until.hour, until.minute);

      if (newFrom.isBefore(newUntil)) {
        newUntil.add(const Duration(days: 1));
      }
    } else if (until.isBefore(from)) {
      newUntil = DateTime(now.year, now.month, now.day + 1, until.hour, until.minute);
    }

    _schedule.from = newFrom.millisecondsSinceEpoch ~/ 1000;
    _schedule.until = newUntil.millisecondsSinceEpoch ~/ 1000;
  }

  String _formatTime(int? timestamp) {
    if (timestamp == null) {
      return "";
    }
    DateTime dt = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    String hour = dt.hour.toString().padLeft(2, '0');
    String minute = dt.minute.toString().padLeft(2, '0');
    return "$hour:$minute";
  }

  String _formatDateTime(int? timestamp) {
    if (timestamp == null) {
      return "";
    }
    DateTime dt = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    String month = dt.month.toString().padLeft(2, '0');
    String day = dt.day.toString().padLeft(2, '0');
    String hour = dt.hour.toString().padLeft(2, '0');
    String minute = dt.minute.toString().padLeft(2, '0');
    return "$day-$month $hour:$minute";
  }

  final List<int> _iconList = [
    0xf107,
    0xef0b,
    0xe1cb,
    0xe5c6,
    0xe185,
    0xe687,
    0xf3c1,
    0xe697,
    0xf078c,
    0xf357,
    0xefc5,
    0xf267,
    0xe037,
    0xf07fd,
    0xf07d2,
    0xf06ec,
    0xe228,
    0xef37,
    0xf17f,
    0xef3d,
    0xe37c,
    0xf0259,
    0xf163,
    0xf08a7,
    0xf06ed,
  ];
}

class FloatInputPicker extends StatefulWidget {
  final double initialValue;
  final double maxVal;
  final double interval;
  final ValueChanged<double> onChanged;

  const FloatInputPicker({
    Key? key,
    required this.initialValue,
    required this.maxVal,
    required this.interval,
    required this.onChanged,
  }) : super(key: key);

  @override
  State<FloatInputPicker> createState() => _FloatInputPickerState();
}

class _FloatInputPickerState extends State<FloatInputPicker> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _selectedIndex = ((widget.initialValue - widget.interval) / widget.interval).round();
  }

  List<Widget> _buildPickerItems() {
    List<Widget> items = [];
    for (double value = widget.interval; value <= widget.maxVal; value += widget.interval) {
      items.add(
        Container(
          alignment: Alignment.center,
          height: 18.0,
          child: Text(value.toStringAsFixed(2)),
        ),
      );
    }
    return items;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      width: 30,
      child: ListWheelScrollView(
        controller: FixedExtentScrollController(initialItem: _selectedIndex),
        itemExtent: 18.0,
        onSelectedItemChanged: (int index) {
          double newValue = widget.interval + index * widget.interval;
          widget.onChanged(newValue);
        },
        useMagnifier: true,
        magnification: 1.2,
        overAndUnderCenterOpacity: 0.5,
        perspective: 0.003,
        children: _buildPickerItems(),
      ),
    );
  }
}

class IntInputPicker extends StatefulWidget {
  final int initialValue;
  final int minVal;
  final int maxVal;
  final int interval;
  final ValueChanged<int> onChanged;

  const IntInputPicker({
    Key? key,
    required this.initialValue,
    required this.minVal,
    required this.maxVal,
    required this.interval,
    required this.onChanged,
  }) : super(key: key);

  @override
  State<IntInputPicker> createState() => _IntInputPickerState();
}

class _IntInputPickerState extends State<IntInputPicker> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _selectedIndex = (widget.initialValue - widget.interval) ~/ widget.interval;
  }

  List<Widget> _buildPickerItems() {
    List<Widget> items = [];
    for (int value = widget.minVal; value <= widget.maxVal; value += widget.interval) {
      items.add(
        Container(
          alignment: Alignment.center,
          height: 18.0,
          child: Text(value.toString()),
        ),
      );
    }
    return items;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      width: 30,
      child: ListWheelScrollView(
        controller: FixedExtentScrollController(initialItem: _selectedIndex),
        itemExtent: 18.0,
        onSelectedItemChanged: (int index) {
          int newValue = widget.minVal + index * widget.interval;
          widget.onChanged(newValue);
        },
        useMagnifier: true,
        magnification: 1.2,
        overAndUnderCenterOpacity: 0.5,
        perspective: 0.003,
        children: _buildPickerItems(),
      ),
    );
  }
}
