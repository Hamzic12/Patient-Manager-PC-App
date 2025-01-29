import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pacienty Management PC',
      theme: ThemeData(
        primaryColor: const Color(0xFF45AC8B), // Set custom primary color
        primarySwatch: createMaterialColor(const Color(0xFF45AC8B)), // Add a primary swatch
      ),
      home: const PacientManagementPC(),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('cs'), // Czech
      ],
    );
  }
  
  MaterialColor createMaterialColor(Color color) {
    List<int> strengths = <int>[50, 100, 200, 300, 400, 500, 600, 700, 800, 900];
    Map<int, Color> swatch = {};
    for (int i = 0; i < strengths.length; i++) {
      final strength = strengths[i];
      swatch[strength] = Color.fromRGBO(
        color.red,
        color.green,
        color.blue,
        (strength + 1) / 1000,
      );
    }
    return MaterialColor(color.value, swatch);
  }
}

class PacientManagementPC extends StatefulWidget {
  const PacientManagementPC({super.key});

  @override
  _PacientManagementPCState createState() => _PacientManagementPCState();
}

class _PacientManagementPCState extends State<PacientManagementPC> {
  String _selectedPage = 'Domů';
  String? _loginName;
  String? _loginTime;

  final List<Map<String, String>> _patientsInfo = [];
  final List<Map<String, dynamic>> _inventoryItems = [];
  final List<Map<String, dynamic>> _meetings = [];

  // Method to determine whether the primaryColor is light or dark
  Color getTextColor(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    // Compute brightness based on the color's luminance
    return primaryColor.computeLuminance() > 0.5 ? Colors.black : Colors.white;
  }

  void _showLoginDialog() {
    String username = '';
    String password = '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Login"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(labelText: "Username"),
                onChanged: (value) {
                  username = value;
                },
              ),
              TextField(
                decoration: const InputDecoration(labelText: "Password"),
                obscureText: true,
                onChanged: (value) {
                  password = value;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                if (username.isNotEmpty && password.isNotEmpty) {
                  setState(() {
                    _loginName = username;
                    _loginTime = DateTime.now().toLocal().toString();
                  });
                  Navigator.of(context).pop(); // Close the dialog
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Please enter valid credentials")),
                  );
                }
              },
              child: const Text("Login"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Pacient Manager PC',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: getTextColor(context),
          ),
        ),
        backgroundColor: Theme.of(context).primaryColor,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.login),
            onPressed: _showLoginDialog, // Show the login dialog when clicked
          ),
        ],
      ),
      body: Row(
        children: [
          Container(
            width: 250,
            color: Colors.grey[200],
            child: ListView(
              children: [
                ListTile(
                  leading: const Icon(Icons.home),
                  title: const Text('Domů'),
                  onTap: () {
                    setState(() {
                      _selectedPage = 'Domů';
                    });
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.people),
                  title: const Text('Pacienti'),
                  onTap: () {
                    setState(() {
                      _selectedPage = 'Pacienti';
                    });
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.schedule),
                  title: const Text('Schůzky'),
                  onTap: () {
                    setState(() {
                      _selectedPage = 'Schůzky';
                    });
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.inventory),
                  title: const Text('Inventář'),
                  onTap: () {
                    setState(() {
                      _selectedPage = 'Inventář';
                    });
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: Center(
              child: _getPageContent(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _getPageContent() {
    if (_selectedPage == 'Domů') {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (_loginName != null && _loginTime != null)
            Column(
              children: [
                Text(
                  'Logged in as: $_loginName',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Login time: $_loginTime',
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            )
          else
            const Text(
              'You are not logged in.',
              style: TextStyle(fontSize: 18),
            ),
        ],
      );
    }

    switch (_selectedPage) {
      case 'Pacienti':
        return _buildPacientiPage();
      case 'Schůzky':
        return _buildSchuzkyPage();
      case "Inventář":
        return _buildInventarPage();
      default:
        return Text(
          'You are viewing the $_selectedPage page.',
          style: const TextStyle(fontSize: 24),
        );
    }
  }

  Widget _buildPacientiPage() { 
    void showFormDialog(BuildContext context, int index) {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();

    if (index != -1) {
      // Pre-fill the form with the person's data
      nameController.text = _patientsInfo[index]['name'] ?? '';
      emailController.text = _patientsInfo[index]['email'] ?? '';
      phoneController.text = _patientsInfo[index]['phone'] ?? '';
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(index == -1 ? 'Přidat pacienta' : 'Upravit pacienta'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Jméno'),
                ),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: 'E-mail'),
                ),
                TextField(
                  controller: phoneController,
                  decoration:
                      const InputDecoration(labelText: 'Telefonní číslo'),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Zrušit'),
            ),
            ElevatedButton(
              onPressed: () {
                final name = nameController.text;
                final email = emailController.text;
                final phone = phoneController.text;

                setState(() {
                  if (index == -1) {
                    _patientsInfo.add({
                      'name': name,
                      'email': email,
                      'phone': phone,
                    });
                  } else {
                    _patientsInfo[index] = {
                      'name': name,
                      'email': email,
                      'phone': phone,
                    };
                  }
                });

                Navigator.of(context).pop();
              },
              child: Text(index == -1 ? 'Přidat' : 'Upravit'),
            ),
          ],
        );
      },
    );
  }

  void showDeleteConfirmationPacientDialog(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Potvrďte vyřazení'),
          content: const Text('Jste si jistý, že chcete pacienta vyřadit?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Ne'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _patientsInfo
                      .removeAt(index); // Remove the person from the list
                });
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Ano'),
            ),
          ],
        );
      },
    );
  }
    
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Centered Title
              const Center(
                child: Text(
                  'Pacienti ordinace',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 16), // Space between title and content

              // Expanded area for the patient list or empty state message
              Expanded(
                child: _patientsInfo.isEmpty
                    ? const Center(
                        child: Text(
                          'Nemáme žádného objednaného pacienta.',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                      )
                    : ListView.builder(
                        itemCount: _patientsInfo.length,
                        itemBuilder: (context, index) {
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            child: ListTile(
                              title: Text(
                                  _patientsInfo[index]['name'] ?? 'Neuvedeno'),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                      'Email: ${_patientsInfo[index]['email'] ?? 'Neuvedeno'}'),
                                  Text(
                                      'Telefon: ${_patientsInfo[index]['phone'] ?? 'Neuvedeno'}'),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Edit Icon
                                  IconButton(
                                    icon: const Icon(Icons.edit),
                                    onPressed: () {
                                      showFormDialog(context, index);
                                    },
                                  ),
                                  // Delete Icon
                                  IconButton(
                                    icon: const Icon(Icons.delete),
                                    onPressed: () {
                                      showDeleteConfirmationPacientDialog(
                                          context, index);
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),

        Positioned(
          bottom: 16,
          right: 16,
          child: FloatingActionButton(
            onPressed: () => showFormDialog(context, -1), // Open form dialog
            backgroundColor:
                Theme.of(context).primaryColor, // Use theme's primary color
            child: const Icon(Icons.add, color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildSchuzkyPage() {
  
  Future<String?> _selectPatient() async {
  return await showDialog<String>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text("Select a Patient"),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _patientsInfo.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(_patientsInfo[index]["name"] ?? "Unknown"),
                onTap: () {
                  Navigator.of(context).pop(_patientsInfo[index]["name"]);
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(null),
            child: const Text("Cancel"),
          ),
        ],
      );
    },
  );
}

Future<DateTime?> _selectDateTime() async {
  DateTime now = DateTime.now();
  DateTime? selectedDate = await showDatePicker(
    context: context,
    initialDate: now,
    firstDate: now,
    lastDate: now.add(const Duration(days: 365)),
  );

  if (selectedDate != null) {
    TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (selectedTime != null) {
      return DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        selectedTime.hour,
        selectedTime.minute,
      );
    }
  }
  return null;
}

  Future<void> _scheduleMeeting() async {
  String? selectedPatient = await _selectPatient();
  if (selectedPatient != null) {
    DateTime? selectedDate = await _selectDateTime();
    if (selectedDate != null) {
      setState(() {
        _meetings.add({"name": selectedPatient, "datetime": selectedDate});
      });
    }
  }
}


  return Scaffold(
    appBar: AppBar(title: const Text("Schůzky")),
    body: _meetings.isEmpty
        ? const Center(child: Text("No scheduled meetings."))
        : ListView.builder(
            itemCount: _meetings.length,
            itemBuilder: (context, index) {
              final meeting = _meetings[index];
              return ListTile(
                title: Text(meeting["name"]),
                subtitle: Text(DateFormat("yyyy-MM-dd HH:mm").format(meeting["datetime"])),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    setState(() {
                      _meetings.removeAt(index);
                    });
                  },
                ),
              );
            },
          ),
    floatingActionButton: FloatingActionButton(
      child: const Icon(Icons.add),
      onPressed: _scheduleMeeting,
    ),
  );
}


  Widget _buildInventarPage() {
    final ImagePicker picker = ImagePicker();

// Method to show the Add Item dialog
  void showAddItemDialog(BuildContext context) {
    final nameController = TextEditingController();
    final capacityController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Přidej vybavení'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Název'),
                ),
                TextField(
                  controller: capacityController,
                  decoration: const InputDecoration(labelText: 'Počet'),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Zrušit'),
            ),
            ElevatedButton(
              onPressed: () {
                final name = nameController.text;
                final capacity = capacityController.text;

                if (name.isNotEmpty && capacity.isNotEmpty) {
                  setState(() {
                    _inventoryItems.add({
                      'name': name,
                      'capacity': capacity,
                      'image': null, // Placeholder image for now
                    });
                  });
                }

                Navigator.of(context).pop();
              },
              child: const Text('Přidat'),
            ),
          ],
        );
      },
    );
  }

// Method to show the Edit Item dialog
  void showEditItemDialog(BuildContext context, int index) {
    final nameController =
        TextEditingController(text: _inventoryItems[index]['name']);
    final capacityController = TextEditingController(
        text: _inventoryItems[index]['capacity'].toString());

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Upravit vybavení'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Název'),
                ),
                TextField(
                  controller: capacityController,
                  decoration: const InputDecoration(labelText: 'Počet'),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Zrušit'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _inventoryItems[index]['name'] = nameController.text;
                  _inventoryItems[index]['capacity'] =
                      int.tryParse(capacityController.text) ?? 0;
                });
                Navigator.of(context).pop();
              },
              child: const Text('Upravit'),
            ),
          ],
        );
      },
    );
  }

void showDeleteConfirmationItemDialog(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Potvrďte odstranění'),
          content:
              const Text('Jste si jistý, že chcete odstranit toto vybavení?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Ne'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _inventoryItems.removeAt(index); // Remove the item
                });
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Ano'),
            ),
          ],
        );
      },
    );
  }

    // Function to update the capacity
    void updateCapacity(int index, int change) {
      setState(() {
        _inventoryItems[index]['capacity'] += change;
        if (_inventoryItems[index]['capacity'] <= 0) {
          _inventoryItems
              .removeAt(index); // Remove the item if capacity reaches 0
        }
      });
    }

    // Function to show delete confirmation dialog
    void showDeleteConfirmation(BuildContext context, int index) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Odebrat předmět'),
            content: const Text('Opravdu chcete tento předmět odebrat?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Ne'),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _inventoryItems.removeAt(index);
                  });
                  Navigator.of(context).pop();
                },
                child: const Text('Ano'),
              ),
            ],
          );
        },
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Centered title for the inventory page
              const Center(
                child: Text(
                  'Inventář',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: _inventoryItems.isEmpty
                    ? const Center(
                        child: Text(
                          'Inventář je prázdný.',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                      )
                    : GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3, // 3 items per row
                          crossAxisSpacing: 10.0,
                          mainAxisSpacing: 10.0,
                          childAspectRatio:
                              0.6, // Adjust for item height and width
                        ),
                        itemCount: _inventoryItems.length,
                        itemBuilder: (context, index) {
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Image placeholder or selected image
                                Container(
                                  width: double.infinity,
                                  height: 200, // Increased height for the image
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                      image: _inventoryItems[index]['image'] !=
                                              null
                                          ? FileImage(_inventoryItems[index]
                                              ['image']) as ImageProvider
                                          : const AssetImage(
                                              'assets/images/placeholder.png'),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 8),
                                Text(
                                  _inventoryItems[index]['name'],
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 8),
                                // Center "Počet" and icons below it
                                Column(
                                  children: [
                                    Text(
                                        'Počet: ${_inventoryItems[index]['capacity']} ks',
                                        textAlign: TextAlign.center),
                                  ],
                                ),
                                // Icons row (Edit, Delete)
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.add),
                                      onPressed: () {
                                        updateCapacity(index, 1);
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.remove),
                                      onPressed: () {
                                        updateCapacity(index, -1);
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.edit),
                                      onPressed: () {
                                        showEditItemDialog(context, index);
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete),
                                      onPressed: () {
                                        showDeleteConfirmation(context, index);
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton(
              onPressed: () => showAddItemDialog(context),
              backgroundColor:
                  Theme.of(context).primaryColor, // Dynamically set color
              child: const Icon(Icons.add, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
