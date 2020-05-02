class Project {
  String name;
  String statuscode;
  String status;
  String message;
  List<Payload> payload;

  Project(
      {this.name, this.statuscode, this.status, this.message, this.payload});

  Project.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    statuscode = json['statuscode'];
    status = json['status'];
    message = json['message'];
    if (json['payload'] != null) {
      payload = new List<Payload>();
      json['payload'].forEach((v) {
        payload.add(new Payload.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['statuscode'] = this.statuscode;
    data['status'] = this.status;
    data['message'] = this.message;
    if (this.payload != null) {
      data['payload'] = this.payload.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Payload {
  String project;
  String scm;
  String workdir;
  bool force;
  List<Stages> stages;
  String metainfo;

  Payload(
      {this.project,
      this.scm,
      this.workdir,
      this.force,
      this.stages,
      this.metainfo});

  Payload.fromJson(Map<String, dynamic> json) {
    project = json['project'];
    scm = json['scm'];
    workdir = json['workdir'];
    force = json['force'];
    if (json['stages'] != null) {
      stages = new List<Stages>();
      json['stages'].forEach((v) {
        stages.add(new Stages.fromJson(v));
      });
    }
    metainfo = json['metainfo'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['project'] = this.project;
    data['scm'] = this.scm;
    data['workdir'] = this.workdir;
    data['force'] = this.force;
    if (this.stages != null) {
      data['stages'] = this.stages.map((v) => v.toJson()).toList();
    }
    data['metainfo'] = this.metainfo;
    return data;
  }
}

class Stages {
  int id;
  String name;
  String exec;
  int wait;
  String service;
  int replicas;
  bool skip;
  List<Envars> envars;
  List<String> commands;

  Stages(
      {this.id,
      this.name,
      this.exec,
      this.wait,
      this.service,
      this.replicas,
      this.skip,
      this.envars,
      this.commands});

  Stages.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    exec = json['exec'];
    wait = json['wait'];
    service = json['service'];
    replicas = json['replicas'];
    skip = json['skip'];
    if (json['envars'] != null) {
      envars = new List<Envars>();
      json['envars'].forEach((v) {
        envars.add(new Envars.fromJson(v));
      });
    }
    commands = json['commands'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['exec'] = this.exec;
    data['wait'] = this.wait;
    data['service'] = this.service;
    data['replicas'] = this.replicas;
    data['skip'] = this.skip;
    if (this.envars != null) {
      data['envars'] = this.envars.map((v) => v.toJson()).toList();
    }
    data['commands'] = this.commands;
    return data;
  }
}

class Envars {
  String name;
  String value;

  Envars({this.name, this.value});

  Envars.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    value = json['value'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['value'] = this.value;
    return data;
  }
}
