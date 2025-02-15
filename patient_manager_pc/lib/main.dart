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
      title: 'UroTep',
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

  final List<Map<String, dynamic>> _patientsInfo = [];
  final List<Map<String, dynamic>> _inventoryItems = [];
  final List<Map<String, dynamic>> _meetings = [];
  DateTime _selectedDay = DateTime.now();

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  // Function to filter the list of patients by name
  void filterPatients(String query) {
    setState(() {
      _searchQuery = query;
    });
  }

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
          title: const Text("Přihlášení"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration:
                    const InputDecoration(labelText: "Uživatelské jméno"),
                onChanged: (value) {
                  username = value;
                },
              ),
              TextField(
                decoration: const InputDecoration(labelText: "Heslo"),
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
              child: const Text("Zrušit"),
            ),
            TextButton(
              onPressed: () {
                if (username == "admin" && password == "1234") {
                  // Format the current date/time in dd-MM-yy hh:mm format
                  String formattedLoginTime = DateFormat('dd.MM.yyyy HH:mm')
                      .format(DateTime.now().toLocal());
                  setState(() {
                    _loginName = username;
                    _loginTime = formattedLoginTime;
                  });
                  Navigator.of(context).pop(); // Close the dialog
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content:
                            Text("Prosím zadejte správné přihlašovací údaje")),
                  );
                }
              },
              child: const Text("Přihlášení"),
            ),
          ],
        );
      },
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Odhlášení"),
          content: const Text("Chcete se odhlásit?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Just close the dialog
              },
              child: const Text("Ne"),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _loginName = null;
                  _loginTime = null;
                  _selectedPage = "Domů";
                });
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text("Ano"),
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
          'UroTep',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: getTextColor(context),
          ),
        ),
        backgroundColor: Theme.of(context).primaryColor,
        centerTitle: true,
        actions: [
          IconButton(
              icon: Icon(_loginName != null ? Icons.logout : Icons.login),
              onPressed: () {
                if (_loginName != null) {
                  _showLogoutDialog();
                } else {
                  _showLoginDialog();
                }
              }),
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
                    if(_loginName != null){
                    setState(() {
                      _selectedPage = 'Pacienti';
                    });
                    }else{
                      _showLoginDialog();
                    }
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.schedule),
                  title: const Text('Schůzky'),
                  onTap: () {
                    if(_loginName != null){
                    setState(() {
                      _selectedPage = 'Schůzky';
                    });
                    }else{
                      _showLoginDialog();
                    }
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.inventory),
                  title: const Text('Inventář'),
                  onTap: () {
                    if(_loginName != null){
                    setState(() {
                      _selectedPage = 'Inventář';
                    });
                    }else{
                      _showLoginDialog();
                    }
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
    switch (_selectedPage) {
      case 'Domů':
        return _buildHomePage();
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

// Home page displaying app info and login details if available.
  Widget _buildHomePage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Vítejte v aplikaci UroTep',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          const Text(
            'Tato aplikace je určena pro personál urologické ordinace. '
            'Správa pacientů, plánování schůzek a správa inventáře - vše na jednom místě.',
            style: TextStyle(fontSize: 18),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 24),
          // Display login information if available
          if (_loginName != null && _loginTime != null)
            Column(
              children: [
                Text(
                  'Příhlášený jako: $_loginName',
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Čas přihlášení: $_loginTime',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 24),
              ],
            )
          else
            const Text(
              'Nejste přihlášeni, prosím, přihlaste se.',
              style: TextStyle(fontSize: 18),
            ),
          const Divider(),
          const SizedBox(height: 24),
          // List app features
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Vlastnosti aplikace:',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 8),
          _buildFeatureItem(Icons.login, 'Přihlášení uživatele'),
          _buildFeatureItem(Icons.logout, 'Odhlášení uživatele'),
          _buildFeatureItem(Icons.people,
              'Přidávání a Správa pacientů, Zobrazení schůzek pacienta'),
          _buildFeatureItem(Icons.schedule, 'Zadávání a zobrazení schůzek'),
          _buildFeatureItem(Icons.inventory, 'Správa inventáře'),
        ],
      ),
    );
  }

  // Helper widget to display a feature with an icon and text.
  Widget _buildFeatureItem(IconData icon, String feature) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).primaryColor),
          const SizedBox(width: 8),
          Text(feature, style: const TextStyle(fontSize: 18)),
        ],
      ),
    );
  }

  Widget _buildPacientiPage() {
    // Filter the patients based on the search query
    List<Map<String, dynamic>> filteredPatients =
        _patientsInfo.where((patient) {
      return patient['name']!
          .toLowerCase()
          .contains(_searchQuery.toLowerCase());
    }).toList();

// Function to edit a patient by their id
    void editPatientById(
        int id, String newName, String newEmail, String newPhone) {
      setState(() {
        // Find the patient with the given id
        int index = _patientsInfo.indexWhere((patient) => patient['id'] == id);

        if (index != -1) {
          // If patient is found, update the patient details
          _patientsInfo[index] = {
            'id': id, // Keep the same id
            'name': newName,
            'email': newEmail,
            'phone': newPhone,
          };
        } else {
          // Optionally handle case where the patient was not found
          print("Pacient s id $id se nenašel.");
        }
      });
    }

    void showFormDialog(BuildContext context, int? id) {
      final nameController = TextEditingController();
      final emailController = TextEditingController();
      final phoneController = TextEditingController();

      // Find the patient by their id
      if (id != null) {
        final patient = _patientsInfo.firstWhere(
          (patient) => patient['id'] == id,
          orElse: () => {
            'id': 0,
            'name': '',
            'email': '',
            'phone': ''
          }, // Return a default empty patient if not found
        );

        if (patient['id'] != 0) {
          // Pre-fill the form with the patient's data
          nameController.text = patient['name'] ?? '';
          emailController.text = patient['email'] ?? '';
          phoneController.text = patient['phone'] ?? '';
        } else {
          // Handle the case where no patient was found (perhaps show an error)
          print('Pacient se nenašel.');
        }
      }

      void savePatient() {
        final newName = nameController.text.trim();
        final newEmail = emailController.text.trim();
        final newPhone = phoneController.text.trim();

        setState(() {
          if (id == null) {
            // Add new patient
            int newId =
                _patientsInfo.isEmpty ? 1 : _patientsInfo.last['id'] + 1;
            _patientsInfo.add({
              'id': newId,
              'name': newName,
              'email': newEmail,
              'phone': newPhone,
            });
          } else {
            // Update existing patient by id
            editPatientById(id, newName, newEmail, newPhone);
          }
        });
      }

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(id == null ? 'Přidat pacienta' : 'Upravit pacienta'),
            content: SingleChildScrollView(
              child: Form(
                key: _formKey, // Add a GlobalKey for validation
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: 'Jméno'),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Jméno je povinné.';
                        }
                        List<String> parts = value.trim().split(RegExp(r'\s+'));
                        if (parts.length < 2) {
                          return 'Zadejte prosím celé jméno i příjmení.';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: emailController,
                      decoration: const InputDecoration(labelText: 'E-mail'),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'E-mail je povinný.';
                        }
                        final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                        if (!emailRegex.hasMatch(value)) {
                          return 'Zadejte platný e-mail.';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: phoneController,
                      decoration: InputDecoration(
                        labelText: 'Telefonní číslo',
                        prefix: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.asset(
                              'assets/images/czech_flag.png', // Czech flag
                              height: 20,
                              width: 20,
                            ),
                            const SizedBox(width: 4),
                            const Text('+420 '),
                          ],
                        ),
                      ),
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Telefonní číslo je povinné.';
                        }
                        final phoneRegex = RegExp(r'^\d{9}$');
                        if (!phoneRegex.hasMatch(value.trim())) {
                          return 'Tel. číslo musí obsahovat přesně 9 číslic.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Zrušit'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // Proceed only if validation passes
                    savePatient();
                    Navigator.pop(context);
                  }
                },
                child: Text(id == null ? 'Přidat' : 'Upravit'),
              ),
            ],
          );
        },
      );
    }

    void deletePatient(int id) {
      setState(() {
        _patientsInfo.removeWhere((patient) => patient['id'] == id);
      });
    }

    void showDeleteConfirmationPacientDialog(BuildContext context, int id) {
      Map<String, dynamic> patient = _patientsInfo.firstWhere(
      (p) => p['id'] == id,
    );

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
                    _patientsInfo.removeWhere((patient) => patient['id'] == id);
                    _meetings.removeWhere((meetings) => meetings["name"] == patient["name"]);
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
                // Vygenerovat dostupné 30minutové termíny
                List<DateTime> availableSlots = [];
                DateTime startTime = DateTime(selectedDate.year,
                    selectedDate.month, selectedDate.day, 8, 0);
                DateTime endTime = DateTime(selectedDate.year,
                    selectedDate.month, selectedDate.day, 18, 0);

                while (startTime.isBefore(endTime)) {
                  // Kontrola, zda je termín již rezervován
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
                  title: const Text("Vyberte čas"),
                  content: availableSlots.isEmpty
                      ? const Text("Žádné dostupné termíny.")
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
                      child: const Text("Zrušit"),
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

    void showPatientMeetingsDialog(
        String patientName, Function(int) editMeeting) {
      List<Map<String, dynamic>> patientMeetings =
          _meetings.where((meeting) => meeting["name"] == patientName).toList();

      patientMeetings.sort((a, b) => a["datetime"].compareTo(b["datetime"]));

      showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setDialogState) {
              // Check if the dialog is still mounted before using setDialogState
              if (!mounted) return Container();

              return AlertDialog(
                title: Text("Schůzky pro $patientName"),
                content: patientMeetings.isEmpty
                    ? const Text("Pacient nemá žádné naplánované schůzky.")
                    : SizedBox(
                        width: double.maxFinite,
                        child: Wrap(
                          spacing: 8.0,
                          runSpacing: 8.0,
                          children: patientMeetings.map((meeting) {
                            DateTime startDateTime = meeting["datetime"];
                            DateTime endDateTime =
                                startDateTime.add(const Duration(minutes: 30));

                            String formattedStartDate =
                                DateFormat("dd-MM-yyyy HH:mm")
                                    .format(startDateTime);
                            String formattedEndDate =
                                DateFormat("dd-MM-yyyy HH:mm")
                                    .format(endDateTime);

                            return Card(
                              color: Colors.blue[100],
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      '$formattedStartDate - $formattedEndDate',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        // Edit button
                                        IconButton(
                                          icon:
                                              const Icon(Icons.edit, size: 18),
                                          onPressed: () async {
                                            int originalIndex =
                                                _meetings.indexWhere(
                                              (m) =>
                                                  m["datetime"] ==
                                                      meeting["datetime"] &&
                                                  m["name"] == meeting["name"],
                                            );
                                            if (originalIndex != -1) {
                                              await editMeeting(
                                                  originalIndex); // Edit meeting

                                              // Only update the dialog if it's still mounted
                                              if (mounted) {
                                                setDialogState(() {
                                                  patientMeetings = _meetings
                                                      .where((m) =>
                                                          m["name"] ==
                                                          patientName)
                                                      .toList();
                                                  patientMeetings.sort((a, b) =>
                                                      a["datetime"].compareTo(
                                                          b["datetime"]));
                                                });
                                              }
                                            }
                                          },
                                        ),
                                        // Delete button
                                        IconButton(
                                          icon: const Icon(Icons.delete,
                                              size: 18),
                                          onPressed: () {
                                            showDialog(
                                              context: context,
                                              builder: (context) {
                                                return AlertDialog(
                                                  title: const Text(
                                                      "Odstranit schůzku"),
                                                  content: const Text(
                                                      "Opravdu chcete odstranit schůzku?"),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () =>
                                                          Navigator.of(context)
                                                              .pop(),
                                                      child: const Text("Ne"),
                                                    ),
                                                    TextButton(
                                                      onPressed: () {
                                                        int originalIndex =
                                                            _meetings
                                                                .indexWhere(
                                                          (m) =>
                                                              m["datetime"] ==
                                                                  meeting[
                                                                      "datetime"] &&
                                                              m["name"] ==
                                                                  meeting[
                                                                      "name"],
                                                        );
                                                        if (originalIndex !=
                                                            -1) {
                                                          setState(() {
                                                            _meetings.removeAt(
                                                                originalIndex);
                                                          });
                                                          setDialogState(() {
                                                            patientMeetings = _meetings
                                                                .where((m) =>
                                                                    m["name"] ==
                                                                    patientName)
                                                                .toList();
                                                            patientMeetings.sort((a,
                                                                    b) =>
                                                                a["datetime"]
                                                                    .compareTo(b[
                                                                        "datetime"]));
                                                          });
                                                        }
                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                      child: const Text("Ano"),
                                                    ),
                                                  ],
                                                );
                                              },
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Zavřít"),
                  ),
                ],
              );
            },
          );
        },
      );
    }

    Future<void> editMeeting(int index) async {
      Map<String, dynamic> meeting = _meetings[index];
      DateTime selectedDateTime = meeting["datetime"];

      await showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setDialogState) {
              return AlertDialog(
                title: const Text("Upravit čas schůzky"),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
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
                          "Změnit čas: ${DateFormat("dd-MM-yyyy HH:mm").format(selectedDateTime)}"),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Zrušit"),
                  ),
                  TextButton(
                    onPressed: () {
                      bool isTimeTaken = _meetings.any((m) =>
                          isSameDay(m["datetime"], selectedDateTime) &&
                          m["datetime"].hour == selectedDateTime.hour &&
                          m["datetime"].minute == selectedDateTime.minute &&
                          m != meeting);
                      if (isTimeTaken) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text("Tento termín je již obsazen!")));
                        return;
                      }

                      // Save changes
                      setState(() {
                        _meetings[index]["datetime"] = selectedDateTime;
                      });

                      // Close the dialog
                      Navigator.pop(context);
                    },
                    child: const Text("Uložit"),
                  ),
                ],
              );
            },
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

              // Search Bar
              TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  labelText: 'Hledej pacienta podle jména...',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  filterPatients(value);
                },
              ),
              const SizedBox(
                  height: 16), // Space between search bar and content

              // Expanded area for the patient list or empty state message
              Expanded(
                  child: filteredPatients.isEmpty
                      ? const Center(
                          child: Text(
                            'Nemáme žádného pacienta.',
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                            textAlign: TextAlign.center,
                          ),
                        )
                      : Wrap(
                          spacing: 10.0, // Horizontal space between cards
                          runSpacing: 10.0, // Vertical space between rows
                          children:
                              List.generate(filteredPatients.length, (index) {
                            return Container(
                              width: 350, // Smaller card width
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.blue[100], // Background color
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    filteredPatients[index]['name'] ??
                                        'Neuvedeno',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                      'Email: ${filteredPatients[index]['email'] ?? 'Neuvedeno'}'),
                                  Text(
                                      'Telefon: ${filteredPatients[index]['phone'] ?? 'Neuvedeno'}'),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      //Show scheduled meetings of patient
                                      IconButton(
                                        icon: const Icon(Icons.event_note),
                                        onPressed: () =>
                                            showPatientMeetingsDialog(
                                                filteredPatients[index]['name']
                                                    .toString(),
                                                editMeeting),
                                      ),

                                      // Edit Icon
                                      IconButton(
                                        icon: const Icon(Icons.edit, size: 18),
                                        onPressed: () {
                                          int patientId =
                                              filteredPatients[index]['id'];
                                          showFormDialog(context, patientId);
                                        },
                                      ),
                                      // Delete Icon
                                      IconButton(
                                        icon:
                                            const Icon(Icons.delete, size: 18),
                                        onPressed: () {
                                          int patientId =
                                              filteredPatients[index]['id'];
                                          showDeleteConfirmationPacientDialog(
                                              context, patientId); // Pass id
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          }),
                        )),
            ],
          ),
        ),
        Positioned(
          bottom: 16,
          right: 16,
          child: FloatingActionButton(
            onPressed: () => showFormDialog(context, null), // Open form dialog
            backgroundColor:
                Theme.of(context).primaryColor, // Use theme's primary color
            child: const Icon(Icons.add, color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildSchuzkyPage() {
    // Helper function to check if two dates are on the same day.
    bool isSameDay(DateTime a, DateTime b) {
      return a.year == b.year && a.month == b.month && a.day == b.day;
    }

    Future<String?> selectPatient() async {
      TextEditingController searchController = TextEditingController();
      String searchQuery = "";

      return await showDialog<String>(
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setDialogState) {
              // Filtrovat pacienty podle dotazu
              List<Map<String, dynamic>> filteredPatients = _patientsInfo
                  .where((patient) => patient["name"]!
                      .toLowerCase()
                      .contains(searchQuery.toLowerCase()))
                  .toList();

              return AlertDialog(
                title: const Text("Vyberte pacienta"),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Vyhledávací pole
                    TextField(
                      controller: searchController,
                      decoration: const InputDecoration(
                        hintText: "Hledat pacienta...",
                        prefixIcon: Icon(Icons.search),
                      ),
                      onChanged: (value) {
                        setDialogState(() {
                          searchQuery = value;
                        });
                      },
                    ),
                    const SizedBox(height: 8),
                    // Seznam pacientů zabalený v kartách
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
                              color: Colors.blue.shade100,
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
                    child: const Text("Zrušit"),
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
                // Vygenerovat dostupné 30minutové termíny
                List<DateTime> availableSlots = [];
                DateTime startTime = DateTime(selectedDate.year,
                    selectedDate.month, selectedDate.day, 8, 0);
                DateTime endTime = DateTime(selectedDate.year,
                    selectedDate.month, selectedDate.day, 18, 0);

                while (startTime.isBefore(endTime)) {
                  // Kontrola, zda je termín již rezervován
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
                  title: const Text("Vyberte čas"),
                  content: availableSlots.isEmpty
                      ? const Text("Žádné dostupné termíny.")
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
                      child: const Text("Zrušit"),
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
            // Update _selectedDay so that the meeting becomes visible in the calendar
            _selectedDay = DateTime(
              selectedDateTime.year,
              selectedDateTime.month,
              selectedDateTime.day,
            );
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
              // Filtrovat pacienty podle dotazu
              List<Map<String, dynamic>> filteredPatients = _patientsInfo
                  .where((patient) => patient["name"]!
                      .toLowerCase()
                      .contains(searchQuery.toLowerCase()))
                  .toList();

              return AlertDialog(
                title: const Text("Upravit schůzku"),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Vyhledávací pole
                    TextField(
                      controller: searchController,
                      decoration: const InputDecoration(
                        hintText: "Hledat pacienta...",
                        prefixIcon: Icon(Icons.search),
                      ),
                      onChanged: (value) {
                        setDialogState(() {
                          searchQuery = value;
                        });
                      },
                    ),
                    const SizedBox(height: 8),
                    // Seznam pacientů zabalený v kartách
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
                    // Vybrat datum a čas (stejné jako ve scheduleMeeting())
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
                          "Změnit čas: ${DateFormat("dd-MM-yyyy HH:mm").format(selectedDateTime)}"),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Zrušit"),
                  ),
                  TextButton(
                    onPressed: () {
                      // Kontrola dvojí rezervace
                      bool isTimeTaken = _meetings.any((m) =>
                          isSameDay(m["datetime"], selectedDateTime) &&
                          m["datetime"].hour == selectedDateTime.hour &&
                          m["datetime"].minute == selectedDateTime.minute &&
                          m != meeting); // Vyloučit aktuální schůzku

                      if (isTimeTaken) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text("Tento termín je již obsazen!")));
                        return;
                      }

                      // Uložit změny
                      setState(() {
                        _meetings[index] = {
                          "name": selectedPatient,
                          "datetime": selectedDateTime
                        };
                      });

                      Navigator.pop(context);
                    },
                    child: const Text("Uložit"),
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
          getMeetingsForDay(_selectedDay);

      if (meetingsForSelectedDay.isEmpty) {
        return const Center(child: Text("V tento den nejsou žádné schůzky."));
      }

      // Sort meetings by start time
      meetingsForSelectedDay
          .sort((a, b) => a["datetime"].compareTo(b["datetime"]));

      return Expanded(
        child: SingleChildScrollView(
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: meetingsForSelectedDay.map((meeting) {
              final startTime = meeting["datetime"];
              final endTime = startTime.add(const Duration(minutes: 30));

              String startTimeFormatted = DateFormat("HH:mm").format(startTime);
              String endTimeFormatted = DateFormat("HH:mm").format(endTime);

              return SizedBox(
                width: MediaQuery.of(context).size.width / 3 - 16,
                child: Card(
                  color: Colors.blue.shade100,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          meeting["name"],
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text("$startTimeFormatted - $endTimeFormatted"),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, size: 20),
                              onPressed: () async {
                                int originalIndex = _meetings.indexWhere(
                                  (m) => m["datetime"] == meeting["datetime"],
                                );

                                if (originalIndex != -1) {
                                  await editMeeting(originalIndex);
                                }
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, size: 20),
                              onPressed: () {
                                setState(() {
                                  _meetings.removeWhere((m) =>
                                      m["datetime"] == meeting["datetime"]);
                                });
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text(
            'Schůzky',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ),
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _selectedDay,
            calendarFormat: CalendarFormat.week, // Zobrazit týdenní pohled
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
                _selectedDay = newSelectedDay;
              });
            },
          ),
          Expanded(child: buildMeetingsList()),
        ],
      ),
      floatingActionButton: Positioned(
        bottom: 16,
        right: 16,
        child: FloatingActionButton(
          onPressed: scheduleMeeting, // or your own function to open dialog
          backgroundColor:
              Theme.of(context).primaryColor, // Dynamically set color
          child: const Icon(Icons.add, color: Colors.white),
        ),
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
