import 'dart:convert';

class Schedule {
  String mode;
  bool? state;
  int? from;
  int? until;
  int? repeat;
  double? cap;
  bool? forever;
  bool? then;
  String? of;
  double? value;
  int? period;

  Schedule.fromJson(Map<String, dynamic> json)
      : mode = json['mode'],
        state = json['state'],
        from = json['from'],
        until = json['until'],
        repeat = json['repeat'],
        cap = (json['cap'] == null) ? null : json['cap'].toDouble(),
        forever = json['forever'],
        then = json['then'],
        of = json['of'],
        value = (json['value'] == null) ? null : json['value'].toDouble(),
        period = json['period'];

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['mode'] = this.mode;
    if (this.state != null) data['state'] = this.state;
    if (this.from != null) data['from'] = this.from;
    if (this.until != null) data['until'] = this.until;
    if (this.repeat != null) data['repeat'] = this.repeat;
    if (this.cap != null) data['cap'] = this.cap;
    if (this.forever != null) data['forever'] = this.forever;
    if (this.then != null) data['then'] = this.then;
    if (this.of != null) data['of'] = this.of;
    if (this.value != null) data['value'] = this.value;
    if (this.period != null) data['period'] = this.period;
    return data;
  }
}
