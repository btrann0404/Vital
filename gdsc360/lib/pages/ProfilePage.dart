import 'package:flutter/material.dart';
import 'package:gdsc360/utils/authservice.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final Auth auth = Auth();
  bool isEditMode = false;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _roleController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _roleController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void toggleEditMode(Map<String, dynamic>? userData) {
    if (userData != null) {
      _nameController.text = userData['name'] ?? '';
      _emailController.text = userData['email'] ?? '';
      _roleController.text = userData['role'] ?? '';
      _phoneController.text = userData['phone_number']?.toString() ?? '';
    }
    setState(() {
      isEditMode = !isEditMode;
    });
  }

  void submitProfileUpdate() {
    try {
      auth.updateUserDetail("name", _nameController.text);
      // auth.updateUserDetail("email", _emailController.text);
      auth.updateUserDetail("role", _roleController.text);
      auth.updateUserDetail("phone_number", _phoneController.text);
      toggleEditMode(null);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Update Successful!')),
      );
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Something Went Wrong!')),
      );
    }
  }

  Widget buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Profile"),
        backgroundColor: const Color.fromARGB(255, 142, 217, 252),
      ),
      body: Container(
        padding: EdgeInsets.only(top: 20),
        width: double.infinity,
        child: FutureBuilder<Map<String, dynamic>?>(
          future: auth.currUserData(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text("Error: ${snapshot.error}");
            } else if (snapshot.hasData) {
              var userData = snapshot.data!;
              return SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    CircleAvatar(
                      radius: 50,
                      backgroundImage:
                          NetworkImage("https://placekitten.com/150/150"),
                    ),
                    SizedBox(height: 10),
                    isEditMode
                        ? Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextFormField(
                              controller: _nameController,
                              decoration: InputDecoration(
                                  labelText: "Name", hintText: "Name"),
                              style: TextStyle(fontSize: 18),
                            ),
                          )
                        : Text(
                            userData['name'] ?? "Name not available",
                            style: TextStyle(
                                fontSize: 32, fontWeight: FontWeight.bold),
                          ),
                    isEditMode
                        ? const SizedBox.shrink()
                        : Text(
                            "Email: ${userData['email'] ?? "Email not available"}",
                            style: TextStyle(
                                fontSize: 18, color: Colors.grey[700]),
                          ),
                    isEditMode
                        ? Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: DropdownButtonFormField<String>(
                                value: _roleController.text.isEmpty
                                    ? null
                                    : _roleController.text,
                                decoration: InputDecoration(
                                  labelText: "Role",
                                  hintText: "Select Role",
                                ),
                                items: ["guardian", "dependent"]
                                    .map((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                                onChanged: (String? newValue) {
                                  setState(() {
                                    _roleController.text = newValue ?? '';
                                  });
                                },
                                style: TextStyle(
                                    fontSize: 18, color: Colors.black)),
                          )
                        : Text(
                            "Role: ${userData['role'] ?? "Role not available"}",
                            style: TextStyle(
                                fontSize: 18, color: Colors.grey[700]),
                          ),
                    isEditMode
                        ? Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextFormField(
                              controller: _phoneController,
                              decoration: InputDecoration(
                                  labelText: "Phone Number",
                                  hintText: "Phone Number"),
                              style: TextStyle(fontSize: 18),
                            ),
                          )
                        : Text(
                            "Phone: ${userData['phone_number'] == 0 ? "Phone Not Added" : userData['phone_number']}",
                            style: TextStyle(
                                fontSize: 18, color: Colors.grey[700]),
                          ),
                    isEditMode
                        ? ElevatedButton(
                            onPressed: () => {},
                            child: Text("Cancel Partnership"))
                        : const SizedBox.shrink(),
                    SizedBox(height: 20),
                    isEditMode
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              ElevatedButton(
                                onPressed: () => toggleEditMode(null),
                                child: Text("Back"),
                              ),
                              ElevatedButton(
                                onPressed: submitProfileUpdate,
                                child: Text("Submit"),
                              ),
                            ],
                          )
                        : ElevatedButton(
                            onPressed: () => toggleEditMode(userData),
                            child: Text("Edit Profile"),
                          ),
                  ],
                ),
              );
            } else {
              return Text("No user data available");
            }
          },
        ),
      ),
    );
  }
}
