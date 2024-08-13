class Sellers{
  String? uid;
  String? name;
  String? email;

  Sellers({
    this.uid,
    this.name,
    this.email,
});

  Sellers.fromJson(Map<String, dynamic> json){
    uid = json["uid"];
    name = json["name"];
    email = json["email"];
  }

  Map<String, dynamic> toJson(){
    final Map<String, dynamic> data = new Map<String,dynamic>();
    data["uid"]=this.uid;
    data["name"]=this.name;
    data["email"]=this.email;
    return data;
  }

}