import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter/services.dart';

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
        primarySwatch: createMaterialColor(
            const Color(0xFF45AC8B)), // Add a primary swatch
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
    List<int> strengths = <int>[
      50,
      100,
      200,
      300,
      400,
      500,
      600,
      700,
      800,
      900
    ];
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
  DateTime _selectedDay = DateTime.now();

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
                    const SnackBar(
                        content: Text("Please enter valid credentials")),
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
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
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
    Future<String?> selectPatient() async {
      TextEditingController searchController = TextEditingController();
      String searchQuery = "";

      return await showDialog<String>(
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setDialogState) {
              /// **Filter patients based on search**
              List<Map<String, String>> filteredPatients = _patientsInfo
                  .where((patient) => patient["name"]!
                      .toLowerCase()
                      .contains(searchQuery.toLowerCase()))
                  .toList();

              return AlertDialog(
                title: const Text("Select a Patient"),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    /// **Search Bar**
                    TextField(
                      controller: searchController,
                      decoration: const InputDecoration(
                        hintText: "Search patient...",
                        prefixIcon: Icon(Icons.search),
                      ),
                      onChanged: (value) {
                        setDialogState(() {
                          searchQuery = value;
                        });
                      },
                    ),
                    const SizedBox(height: 8),

                    /// **Patients List (Wrap with Cards)**
                    SingleChildScrollView(
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: filteredPatients.map((patient) {
                          return GestureDetector(
                            onTap: () {
                              Navigator.of(context).pop(patient["name"]);
                            },
                            child: Card(
                              color: Colors.blue.shade100, // Background color
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 8, horizontal: 12),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      patient["name"]!,
                                      style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
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
        },
      );
    }

    Future<DateTime?> selectDateTime() async {
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

    Future<DateTime?> selectDateTimeWithSlots(DateTime initialDate) async {
      DateTime now = DateTime.now();
      DateTime? selectedDate = await showDatePicker(
        context: context,
        initialDate: initialDate,
        firstDate: now,
        lastDate: now.add(const Duration(days: 365)),
      );

      if (selectedDate != null) {
        return await showDialog<DateTime>(
          context: context,
          builder: (context) {
            return StatefulBuilder(
              builder: (context, setDialogState) {
                /// **Generate available 30-minute slots**
                List<DateTime> availableSlots = [];
                DateTime startTime = DateTime(selectedDate.year,
                    selectedDate.month, selectedDate.day, 8, 0);
                DateTime endTime = DateTime(selectedDate.year,
                    selectedDate.month, selectedDate.day, 18, 0);

                while (startTime.isBefore(endTime)) {
                  /// **Check if slot is already booked**
                  bool isTaken = _meetings.any((meeting) =>
                      isSameDay(meeting["datetime"], startTime) &&
                      meeting["datetime"].hour == startTime.hour &&
                      meeting["datetime"].minute == startTime.minute);

                  if (!isTaken) {
                    availableSlots.add(startTime);
                  }

                  startTime = startTime.add(const Duration(minutes: 30));
                }

                return AlertDialog(
                  title: const Text("Select Time"),
                  content: availableSlots.isEmpty
                      ? const Text("No available time slots.")
                      : Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: availableSlots.map((slot) {
                            return ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context, slot);
                              },
                              child: Text(DateFormat("HH:mm").format(slot)),
                            );
                          }).toList(),
                        ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Cancel"),
                    ),
                  ],
                );
              },
            );
          },
        );
      }
      return null;
    }

    Future<void> scheduleMeeting() async {
      String? selectedPatient = await selectPatient();
      if (selectedPatient != null) {
        DateTime now = DateTime.now();
        DateTime? selectedDateTime = await selectDateTimeWithSlots(now);
        if (selectedDateTime != null) {
          setState(() {
            _meetings
                .add({"name": selectedPatient, "datetime": selectedDateTime});
          });
        }
      }
    }

    DateTime selectedDay = DateTime.now();

    List<Map<String, dynamic>> getMeetingsForDay(DateTime day) {
      return _meetings
          .where((meeting) => isSameDay(meeting["datetime"], day))
          .toList();
    }

    Future<void> editMeeting(int index) async {
      Map<String, dynamic> meeting = _meetings[index];
      String? selectedPatient = meeting["name"];
      DateTime selectedDateTime = meeting["datetime"];

      TextEditingController searchController = TextEditingController();
      String searchQuery = "";

      await showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setDialogState) {
              /// **Filter patients based on search**
              List<Map<String, String>> filteredPatients = _patientsInfo
                  .where((patient) => patient["name"]!
                      .toLowerCase()
                      .contains(searchQuery.toLowerCase()))
                  .toList();

              return AlertDialog(
                title: const Text("Edit Meeting"),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    /// **Search Bar**
                    TextField(
                      controller: searchController,
                      decoration: const InputDecoration(
                        hintText: "Search patient...",
                        prefixIcon: Icon(Icons.search),
                      ),
                      onChanged: (value) {
                        setDialogState(() {
                          searchQuery = value;
                        });
                      },
                    ),
                    const SizedBox(height: 8),

                    /// **Patients List (Wrap with Cards)**
                    SingleChildScrollView(
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: filteredPatients.map((patient) {
                          return GestureDetector(
                            onTap: () {
                              setDialogState(() {
                                selectedPatient = patient["name"];
                              });
                            },
                            child: Card(
                              color: selectedPatient == patient["name"]
                                  ? Colors.blue.shade300
                                  : Colors.blue.shade100,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 8, horizontal: 12),
                                child: Text(
                                  patient["name"]!,
                                  style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),

                    const SizedBox(height: 10),

                    /// **Pick Date & Time (Same as in `scheduleMeeting()`)**
                    ElevatedButton(
                      onPressed: () async {
                        DateTime? newDateTime =
                            await selectDateTimeWithSlots(selectedDateTime);
                        if (newDateTime != null) {
                          setDialogState(() {
                            selectedDateTime = newDateTime;
                          });
                        }
                      },
                      child: Text(
                          "Change Time: ${DateFormat("yyyy-MM-dd HH:mm").format(selectedDateTime)}"),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Cancel"),
                  ),
                  TextButton(
                    onPressed: () {
                      /// **Prevent double booking**
                      bool isTimeTaken = _meetings.any((m) =>
                          isSameDay(m["datetime"], selectedDateTime) &&
                          m["datetime"].hour == selectedDateTime.hour &&
                          m["datetime"].minute == selectedDateTime.minute &&
                          m != meeting); // Exclude the current meeting

                      if (isTimeTaken) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content:
                                    Text("This time slot is already taken!")));
                        return;
                      }

                      /// **Save Changes**
                      setState(() {
                        _meetings[index] = {
                          "name": selectedPatient,
                          "datetime": selectedDateTime
                        };
                      });

                      Navigator.pop(context);
                    },
                    child: const Text("Save"),
                  ),
                ],
              );
            },
          );
        },
      );
    }

    Widget buildMeetingsList() {
      List<Map<String, dynamic>> meetingsForSelectedDay =
          getMeetingsForDay(selectedDay);

      if (meetingsForSelectedDay.isEmpty) {
        return const Center(child: Text("No meetings on this day."));
      }

      return ListView.builder(
        itemCount: meetingsForSelectedDay.length,
        itemBuilder: (context, index) {
          final meeting = meetingsForSelectedDay[index];

          return Card(
            color: Colors.blue.shade100, // Background color for card
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            child: ListTile(
              title: Text(meeting["name"],
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(DateFormat("HH:mm").format(meeting["datetime"])),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  /// **Edit Button**
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.black54),
                    onPressed: () => editMeeting(index),
                  ),

                  /// **Delete Button**
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      setState(() {
                        _meetings.removeAt(index);
                      });
                    },
                  ),
                ],
              ),
            ),
          );
        },
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Schůzky")),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _selectedDay,
            calendarFormat: CalendarFormat.week, // Show week view
            eventLoader: (day) => getMeetingsForDay(day),
            headerStyle: const HeaderStyle(formatButtonVisible: false),
            calendarStyle: const CalendarStyle(
              todayDecoration: BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
            ),
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (newSelectedDay, focusedDay) {
              setState(() {
                _selectedDay = newSelectedDay; // Correctly update selectedDay
              });
            },
          ),
          Expanded(child: buildMeetingsList()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: scheduleMeeting,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildInventarPage() {
    final ImagePicker picker = ImagePicker();

// Method to show the Add Item dialog
    void showAddItemDialog(BuildContext context) {
      final nameController = TextEditingController();
      final capacityController = TextEditingController();
      XFile? pickedImage;

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
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                  const SizedBox(height: 10),
                  // Button for selecting an image
                  ElevatedButton(
                    onPressed: () async {
                      final pickedFile =
                          await picker.pickImage(source: ImageSource.gallery);
                      if (pickedFile != null) {
                        setState(() {
                          pickedImage = pickedFile;
                        });
                      }
                    },
                    child: const Text('Vyber obrázek'),
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
                        'capacity': int.tryParse(capacity ?? '0') ?? 0,
                        'image': pickedImage != null
                            ? File(pickedImage!.path)
                            : null, // Image or null
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
      XFile? pickedImage;

      // If there is already an image, use it for editing
      if (_inventoryItems[index]['image'] != null) {
        pickedImage = XFile(_inventoryItems[index]['image']!.path);
      }

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
                  const SizedBox(height: 10),
                  // Button for selecting an image
                  ElevatedButton(
                    onPressed: () async {
                      final pickedFile =
                          await picker.pickImage(source: ImageSource.gallery);
                      if (pickedFile != null) {
                        setState(() {
                          pickedImage = pickedFile;
                        });
                      }
                    },
                    child: const Text('Vyber obrázek'),
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
                    // Set the new image if picked, otherwise keep it null
                    _inventoryItems[index]['image'] =
                        pickedImage != null ? File(pickedImage!.path) : null;
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
                      : Wrap(
                          spacing: 10.0, // Horizontal space between cards
                          runSpacing: 10.0, // Vertical space between cards
                          children:
                              List.generate(_inventoryItems.length, (index) {
                            return SizedBox(
                              width: 160, // Specify the width of the card
                              height: 240, // Specify the height of the card
                              child: Card(
                                margin: const EdgeInsets.symmetric(vertical: 8),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // Image placeholder or selected image
                                    Container(
                                      width: double.infinity,
                                      height:
                                          120, // You can also adjust this to make the image smaller
                                      decoration: BoxDecoration(
                                        image: DecorationImage(
                                          image: _inventoryItems[index]
                                                      ['image'] !=
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
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                    // Icons row (Edit, Delete)
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
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
                                            showDeleteConfirmation(
                                                context, index);
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                        )),
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
