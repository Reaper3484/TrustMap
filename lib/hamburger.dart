import 'package:flutter/material.dart';

var largeBorderRadius = 28.0;
var mediumBorderRadius = 20.0;
var smallBorderRadius = 16.0;

class HamburgerMenu extends StatefulWidget {
  const HamburgerMenu({super.key});

  @override
  State<HamburgerMenu> createState() => _HamburgerMenuState();
}

class _HamburgerMenuState extends State<HamburgerMenu> {
  bool isMenuOpen = false;
  bool isMenuFullyExpanded = false;

  bool safetyTimerEnabled = true;
  String safetyTimerDuration = "2 minutes";
  bool sosEnabled = true;
  bool soundAlarm = true;
  bool voiceRecording = true;
  bool cameraRecording = true;

  List<Map<String, String>> contacts = [];

void signOut(BuildContext context) async {

}



  void _addContact() {
    TextEditingController nameController = TextEditingController();
    TextEditingController phoneController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Add Contact"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: "Name"),
              ),
              TextField(
                controller: phoneController,
                decoration: InputDecoration(labelText: "Phone Number"),
                keyboardType: TextInputType.phone,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                String phoneNumber = phoneController.text.trim();

                if (nameController.text.isNotEmpty && phoneNumber.isNotEmpty) {
                  if (phoneNumber.length == 10 &&
                      RegExp(r'^\d{10}$').hasMatch(phoneNumber)) {
                    setState(() {
                      contacts.add({
                        "name": nameController.text,
                        "phone": phoneNumber,
                      });
                    });
                    Navigator.of(context).pop();
                  } else {
                    // Show an alert dialog for an invalid phone number
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text("Error"),
                          content: Text(
                              "Invalid phone number. Please enter a 10-digit number."),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text("OK"),
                            ),
                          ],
                        );
                      },
                    );
                  }
                }
              },
              child: Text("Add"),
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: 40,
          left: 20,
          child: AnimatedContainer(
            duration: Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            onEnd: () {
              setState(() {
                isMenuFullyExpanded = isMenuOpen;
              });
            },
            width: isMenuOpen ? 370 : 55,
            height: isMenuOpen ? 600 : 55,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(mediumBorderRadius),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey,
                  blurRadius: 1,
                ),
              ],
            ),
            child: isMenuOpen && isMenuFullyExpanded
                ? Padding(
                    padding: EdgeInsets.all(28.0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              "Settings",
                              style: TextStyle(
                                  fontSize: 25,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black),
                            ),
                            IconButton(
                              icon: Icon(Icons.close, color: Colors.black),
                              onPressed: () {
                                setState(() {
                                  isMenuOpen = false;
                                  isMenuFullyExpanded = false;
                                });
                              },
                            ),
                          ],
                        ),
                        Divider(
                            color: const Color.from(
                                alpha: 1,
                                red: 0.804,
                                green: 0.804,
                                blue: 0.804)),
                        Row(
                          children: [
                            Text("",
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black)),
                          ],
                        ),
                        Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Safety Timer",
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black)),
                                SwitchListTile(
                                  title: Text("Enabled",
                                      style: TextStyle(color: Colors.black)),
                                  value: safetyTimerEnabled,
                                  onChanged: (bool value) {
                                    setState(() {
                                      safetyTimerEnabled = value;
                                    });
                                  },
                                  activeTrackColor: Colors.black,
                                  activeColor: Colors.white,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        "    Duration",
                                        style: TextStyle(
                                            fontSize: 16, color: Colors.black),
                                        textAlign: TextAlign
                                            .start, // Ensures alignment with other fields
                                      ),
                                    ),
                                    SizedBox(
                                      width: 150,
                                      child: DropdownButton<String>(
                                        value: safetyTimerDuration,
                                        isExpanded: true,
                                        dropdownColor: Colors.white,
                                        borderRadius: BorderRadius.circular(16),
                                        items: [
                                          "1 minute",
                                          "2 minutes",
                                          "5 minutes",
                                          "10 minutes",
                                          "20 minutes"
                                        ].map((String value) {
                                          return DropdownMenuItem<String>(
                                            value: value,
                                            child: Text(value,
                                                style: TextStyle(
                                                    color: Colors.black)),
                                          );
                                        }).toList(),
                                        onChanged: (String? newValue) {
                                          setState(() {
                                            safetyTimerDuration = newValue!;
                                          });
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 10),
                                Text("SOS",
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black)),
                                SwitchListTile(
                                  title: Text("Enabled",
                                      style: TextStyle(color: Colors.black)),
                                  value: sosEnabled,
                                  onChanged: (bool value) {
                                    setState(() {
                                      sosEnabled = value;
                                    });
                                  },
                                  activeTrackColor: Colors.black,
                                  activeColor: Colors.white,
                                ),
                                SwitchListTile(
                                  title: Text("Sound alarm",
                                      style: TextStyle(color: Colors.black)),
                                  value: soundAlarm,
                                  onChanged: (bool value) {
                                    setState(() {
                                      soundAlarm = value;
                                    });
                                  },
                                  activeTrackColor: Colors.black,
                                  activeColor: Colors.white,
                                ),
                                SwitchListTile(
                                  title: Text("Begin audio recording",
                                      style: TextStyle(color: Colors.black)),
                                  value: voiceRecording,
                                  onChanged: (bool value) {
                                    setState(() {
                                      voiceRecording = value;
                                    });
                                  },
                                  activeTrackColor: Colors.black,
                                  activeColor: Colors.white,
                                ),
                                SwitchListTile(
                                  title: Text("Begin camera recording",
                                      style: TextStyle(color: Colors.black)),
                                  value: cameraRecording,
                                  onChanged: (bool value) {
                                    setState(() {
                                      cameraRecording = value;
                                    });
                                  },
                                  activeTrackColor: Colors.black,
                                  activeColor: Colors.white,
                                ),
                                SizedBox(height: 10),
                                Text("Contacts",
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black)),
                                Column(
                                  children: contacts.map((contact) {
                                    return ListTile(
                                      title: Text(contact["name"]!,
                                          style:
                                              TextStyle(color: Colors.black)),
                                      subtitle: Text(contact["phone"]!,
                                          style:
                                              TextStyle(color: Colors.black)),
                                    );
                                  }).toList(),
                                ),
                                TextButton.icon(
                                  onPressed: _addContact,
                                  icon: Icon(Icons.add, color: Colors.black),
                                  label: Text("Add Contact",
                                      style: TextStyle(color: Colors.black)),
                                ),
                                SizedBox(height: 10),
                                ElevatedButton(
                                  onPressed: () {
                                    // Sign-out logic here
                                    signOut;
                                    print("User signed out");
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color.fromARGB(
                                        255, 0, 0, 0), // Button color
                                    foregroundColor: const Color.fromARGB(
                                        255, 255, 255, 255), // Text color
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(50),
                                    ),
                                  ),
                                  child: Text("Sign out",
                                      style: TextStyle(fontSize: 16)),
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : FloatingActionButton(
                    onPressed: () {
                      setState(() {
                        isMenuOpen = true;
                      });
                    },
                    backgroundColor: Colors.white,
                    child: Icon(Icons.menu, color: Colors.black),
                  ),
          ),
        ),
      ],
    );
  }
}
