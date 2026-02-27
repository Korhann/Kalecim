import 'package:cloud_firestore/cloud_firestore.dart';

class BildirimModel {
String id;
String text;
Timestamp createdAt;

BildirimModel(this.id,this.text,this.createdAt);

static Map<String,dynamic> toMap({required BildirimModel bildirimmodel}){
return {
BildirimModelFields.id : bildirimmodel.id,
BildirimModelFields.text : bildirimmodel.text,
BildirimModelFields.createdAt : bildirimmodel.createdAt
};
}

static BildirimModel fromMap({required Map<String,dynamic> data}){
String id = data[BildirimModelFields.id];
String text = data[BildirimModelFields.text];
Timestamp createdAt = data[BildirimModelFields.createdAt];
return BildirimModel(id,text,createdAt);

}
}

class BildirimModelFields {
static const String id = 'id';
static const String text = 'text';
static const String createdAt = 'createdAt';
}