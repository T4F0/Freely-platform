// ignore_for_file: must_be_immutable
import 'package:equatable/equatable.dart';
import 'package:flut/consts/hive_consts.dart';
import 'package:hive/hive.dart';


const String FREELACNER = "freelancer"; 
const String CLIENT = "client"; 

class UserModel extends Equatable {
  String firstName;
  String lastName;
  String id;
  String ccp;
  String email;
  String role;
  String token;

  String willaya = "algria";
  String photo = "";
  String phoneNumber = "0686249238";
  String dateOfBirth = "1969/2/29";
  int activeJobs = 0;
  int completedJobs = 0;
  int moneySum = 0;
  String bio;

  UserModel({
    required this.firstName,
    required this.lastName,
    required this.id,
    required this.ccp,
    required this.email,
    required this.role,
    required this.token,
    required this.bio,
    
    this.willaya = "",
    this.photo = "",
    this.phoneNumber = "",
    this.dateOfBirth = "",
    this.activeJobs = 0,
    this.completedJobs = 0,
    this.moneySum = 0,
  });

  void hive_store_self(Box box) {
    box.put("firstName", firstName);
    box.put("lastName", lastName);
    box.put("id", id);
    box.put("ccp", ccp);
    box.put("email", email);
    box.put("role", role);
    box.put(HiveConsts.JWT_TOKEN, token);
  }

  void hive_load_self(Box box) {
    firstName = box.get("firstName");
    lastName = box.get("lastName");
    id = box.get("id");
    ccp = box.get("ccp");
    email = box.get("email");
    role = box.get("role");
    token = box.get(HiveConsts.JWT_TOKEN);
  }

  factory UserModel.loadFromHive(Box box) {
    return UserModel(
      firstName: box.get("firstName"),
      lastName: box.get("lastName"),
      id: box.get("id"),
      ccp: box.get("ccp"),
      email: box.get("email"),
      role: box.get("role"),
      bio: "",
      token: box.get(HiveConsts.JWT_TOKEN),
    );
  }

  factory UserModel.fromLogin(Map<String, dynamic> data) {
    Map<String, dynamic> client = data["user"];
    print(client);
    return UserModel(
      firstName: client["firstName"],
      lastName: client["lastName"],
      id: client["id"],
      ccp: client["ccp"],
      email: client["email"],
      role: client["role"],
      token: data["token"],
      bio: data["bio"] ?? ""
    );
  }

  factory UserModel.fromRegister(Map<String, dynamic> data) {
    return UserModel.fromLogin(data);
  }

  factory UserModel.fromProfile(Map<String, dynamic> user) {
    return UserModel(
      firstName: user["firstName"],
      lastName: user["lastName"],
      id: "",
      ccp: user["ccp"],
      email: user["email"],
      role: user["role"] == "freelancer" ? FREELACNER : CLIENT,
      token: "",
      willaya: user["willaya"] ?? "algria",
      photo: user["photo"] ?? "",
      bio: user["bio"] ?? "",
      phoneNumber: user["phoneNumber"] ?? "0686249238",
      dateOfBirth: user["dateOfBirth"] ?? "1969/2/29",
    );
  }

  @override
  List<Object> get props => [
        firstName,
        lastName,
        id,
        ccp,
        email,
        role,
        token,
        willaya,
        photo,
        phoneNumber,
        dateOfBirth,
        activeJobs,
        completedJobs,
        moneySum,
      ];
}
