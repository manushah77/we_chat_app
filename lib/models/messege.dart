class Messges {
  String? toId;
  String? fromId;
  String? msg;
  String? read;
  Typee? type;
  String? sent;

  Messges({this.fromId, this.msg, this.read, this.sent, this.toId, this.type});

  Messges.fromJson(Map<String, dynamic> json) {
    toId = json['toId'].toString();
    msg = json['msg'].toString();
    fromId = json['fromId'].toString();
    type = json['type'].toString() == Typee.image.name ? Typee.image : Typee.text;
    sent = json['sent'].toString();
    read = json['read'].toString();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};

    data['toId'] = toId;
    data['msg'] = msg;
    data['fromId'] = fromId;
    data['type'] = type!.name;
    data['sent'] = sent;
    data['read'] = read;
    return data;
  }
}

enum Typee {
  text, image;
}
