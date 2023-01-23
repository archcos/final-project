import 'package:finalproject/csidebar/collapsible_sidebar.dart';
import 'package:flutter/material.dart';
import 'package:finalproject/util/data_model.dart';
import 'package:finalproject/util/database.dart';
import 'package:finalproject/screen/home.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:permission_handler/permission_handler.dart';
import 'dart:convert' as convert;

Future<DataModel> postAccount(int? id, String firstname, String lastname, String username, String password, String email) async {
  final response = await http.post(
    Uri.parse("https://63c95a0e320a0c4c9546afb1.mockapi.io/api/users"),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<dynamic, dynamic>{
      'id': id,
      'firstname': firstname,
      'lastname': lastname,
      'username': username,
      'password': password,
      'email': email
    }),
  );

  if (response.statusCode == 201) {
    return DataModel.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('Failed to Add Todo');
  }
}
class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  final TextEditingController userNameController = TextEditingController();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

 
  List accounts = <dynamic>[];
  List account = <dynamic>[];
  var formKey = GlobalKey<FormState>();
  List<DataModel> data = [];
  bool fetching = true;
  late int currentIndex;
  late DB db;

  @override
  void initState() {
    super.initState();
    db = DB();
    db.initDB();
    checkPermission();
    getUsers();
    checkLogin();
  }



  checkPermission() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.storage,
      Permission.camera,
    ].request();
    statuses[Permission.storage];
  }


  getUsers() async {
    var url = 'https://63c95a0e320a0c4c9546afb1.mockapi.io/api/users';
    var response = await http.get(Uri.parse(url));

    setState(() {
      accounts = convert.jsonDecode(response.body) as List<dynamic>;
    }
    );
  }

  Future loginData() async {
    var username = userNameController.text;
    var password = passwordController.text;
    showDialog(
        context: context,
        builder: (context) {
          return const Center(
              child: CircularProgressIndicator()
          );
        });
    Navigator.of(context).pop();

    for (var i = 0; i <= accounts.length; i++) {
      if (username == accounts[i]['username'] &&
          password == accounts[i]['password']) {
        _showMsg('Login Success');
        account.add(accounts[i]);
        await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => HomePage(data: account))
        );


        break;
      }
    }
  }

  _showMsg(msg) {
    final snackBar = SnackBar(
        content: Text(msg),
        action: SnackBarAction(
          label: 'Close',
          onPressed: () {},
        ));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }


  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    userNameController.dispose();
    passwordController.dispose();
    super.dispose();
  }
  void checkLogin () async {
    //HERE WE CHECK IF USER ALREADY LOGIN OR CREDENTIAL ALREADY AVAILABLE OR NOT
    SharedPreferences pref = await SharedPreferences.getInstance();
    String? val = pref.getString("login");
    if (val != null) {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => HomePage(data: [],)),
              (route) => false);

    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Form(
            key: formKey,
            child: ListView(
                padding: const EdgeInsets.all(30),
                children: [
                  const Image(image: AssetImage("assets/logo.png"),
                      width: 300,
                      height: 300),
                  const Text("ANONYMITY", style: TextStyle(fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center),
                  const SizedBox(height: 50),
                  TextFormField(
                    controller: userNameController,
                    keyboardType: TextInputType.name,
                    decoration: InputDecoration(
                      labelText: "Username",
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 10.0),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5.0)),
                    ),
                    validator: (value) {
                      return (value == '') ? "Input Name" : null;
                    },
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                      controller: passwordController,
                      keyboardType: TextInputType.name,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        hintText: 'Enter your password',
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 10.0),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5.0)),
                      )
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                      onPressed: () {
                        loginData();
                        login();
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.greenAccent
                      ),
                      child: const Text("Sign In",
                          style: TextStyle(color: Colors.black, fontSize: 17))
                  ),
                  TextButton(
                      onPressed: () {
                        showMyDialogue();
                      },
                      child: const Text("Create Account")
                  )
                ]
            )
        )
    );
  }

  void login() async {
    if (passwordController.text.isNotEmpty && emailController.text.isNotEmpty) {
      var response = await http.post(
          Uri.parse("https://63c95a0e320a0c4c9546afb1.mockapi.io/api/login"),
          body: ({
            "email": emailController.text,
            "password": passwordController.text
          }));
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        //print("Login Token" + body.["token"]);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Token : ${body['token']}")));

        pageRoute(body['token']);
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Invalid Credentials")));
      }
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Blank Value Found")));
    }
  }
    void pageRoute(String token) async {
      //HERE WE STORE VALUE OR TOKEN INSIDE SHARED PREFERENCES
      SharedPreferences pref = await SharedPreferences.getInstance();
      await pref.setString("login", token);
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => HomePage(data: [],)),
              (route) => false);
    }



  void showMyDialogue() async {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            scrollable: true,
            title: const Text('Create Account'),
            content: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Form(
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  children: [
                    TextFormField(
                      controller: firstNameController,
                      keyboardType: TextInputType.name,
                      decoration: const InputDecoration(
                          labelText: "First Name"),
                      validator: (value){
                        return (value == '')? "Input First Name" : null;
                      },
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: lastNameController,
                      keyboardType: TextInputType.name,
                      decoration: const InputDecoration(
                          labelText: "Last Name"),
                      validator: (value){
                        return (value == '')? "Input Last Name" : null;
                      },
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: userNameController,
                      keyboardType: TextInputType.name,
                      decoration: const InputDecoration(
                          labelText: "Username"),
                      validator: (value){
                        return (value == '')? "Input Username" : null;
                      },
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: passwordController,
                      keyboardType: TextInputType.name,
                      obscureText: true,
                      decoration: const InputDecoration(
                          labelText: "Password"),
                      validator: (value){
                        return (value == '')? "Input Password" : null;
                      },
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                          labelText: "Email Address"),
                      validator: (value){
                        return (value == '')? "Input Email Address" : null;
                      },
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    Navigator.pop(context);
                    currentIndex = accounts.lastIndexOf('id', 0);
                    DataModel dataLocal = DataModel(
                      firstname: firstNameController.text,
                      lastname: lastNameController.text,
                      username: userNameController.text,
                      password: passwordController.text,
                      email: emailController.text,
                    );
                    db.insertData(dataLocal);
                    setState(() {
                      postAccount(
                          currentIndex,
                          firstNameController.text,
                          lastNameController.text,
                          userNameController.text,
                          passwordController.text,
                          emailController.text
                      );
                    });
                    firstNameController.clear();
                    lastNameController.clear();
                    userNameController.clear();
                    passwordController.clear();
                    emailController.clear();
                  }
                },
                child: const Center(
                  child: Text("Sign Up"),
                ),
              ),
            ],
          );
        });
  }

}
