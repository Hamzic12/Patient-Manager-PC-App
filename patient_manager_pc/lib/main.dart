import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

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
  final List<Map<String, String>> _submittedData = [];
  final List<Map<String, dynamic>> _inventoryItems = [];

  // Method to determine whether the primaryColor is light or dark
  Color getTextColor(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    // Compute brightness based on the color's luminance
    return primaryColor.computeLuminance() > 0.5 ? Colors.black : Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Pacient Manager PC',
          style: TextStyle(
              fontWeight: FontWeight.bold,
              color: getTextColor(context)), // Title text styling
        ),
        backgroundColor:
            Theme.of(context).primaryColor, // Background color of the header
        centerTitle: true, // Center the title
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
                child: _submittedData.isEmpty
                    ? const Center(
                        child: Text(
                          'Nemáme žádného pacienta.',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                      )
                    : ListView.builder(
                        itemCount: _submittedData.length,
                        itemBuilder: (context, index) {
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            child: ListTile(
                              title: Text(
                                  _submittedData[index]['name'] ?? 'Neuvedeno'),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                      'Email: ${_submittedData[index]['email'] ?? 'Neuvedeno'}'),
                                  Text(
                                      'Phone: ${_submittedData[index]['phone'] ?? 'Neuvedeno'}'),
                                  Text(
                                      'Submission Time: ${_submittedData[index]['time'] ?? 'Neuvedeno'}'),
                                  Text(
                                      'Selected Date & Time: ${_submittedData[index]['selectedDateTime'] ?? 'Neuvedeno'}'),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Edit Icon
                                  IconButton(
                                    icon: const Icon(Icons.edit),
                                    onPressed: () {
                                      _showFormDialog(context, index);
                                    },
                                  ),
                                  // Delete Icon
                                  IconButton(
                                    icon: const Icon(Icons.delete),
                                    onPressed: () {
                                      _showDeleteConfirmationPacientDialog(
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
            onPressed: () => _showFormDialog(context, -1), // Open form dialog
            backgroundColor:
                Theme.of(context).primaryColor, // Use theme's primary color
            child: const Icon(Icons.add, color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildSchuzkyPage() {
    // Get today's date
    final today = DateTime.now();
    final dateFormatter = DateFormat('yyyy-MM-dd');
    final currentDate = dateFormatter.format(today);

    // Filter persons that have appointments on today's date
    final todayAppointments = _submittedData.where((person) {
      return person['selectedDateTime'] != null &&
          person['selectedDateTime']!.startsWith(currentDate);
    }).toList();

    // Sort appointments by start time
    todayAppointments.sort((a, b) {
      final timeA =
          DateFormat('yyyy-MM-dd HH:mm').parse(a['selectedDateTime']!);
      final timeB =
          DateFormat('yyyy-MM-dd HH:mm').parse(b['selectedDateTime']!);
      return timeA.compareTo(timeB);
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Schůzky'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Rozvrh na $currentDate',
                style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: _buildTimetable(todayAppointments),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInventarPage() {
    final ImagePicker picker = ImagePicker();

    void showAddItemDialog(BuildContext context) async {
      final nameController = TextEditingController();
      final capacityController = TextEditingController();
      XFile? pickedImage;

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Přidej předmět'),
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
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          final pickedFile = await picker.pickImage(
                            source: ImageSource.gallery,
                          );
                          if (pickedFile != null) {
                            pickedImage = pickedFile;
                          }
                        },
                        child: const Text('Vybrat obrázek'),
                      ),
                    ],
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
                        'capacity': int.tryParse(capacity) ?? 0,
                        'image': pickedImage != null
                            ? File(pickedImage!.path)
                            : null,
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

    // Function to show the edit item dialog
    void showEditItemDialog(BuildContext context, int index) {
      final nameController =
          TextEditingController(text: _inventoryItems[index]['name']);
      final capacityController = TextEditingController(
          text: _inventoryItems[index]['capacity'].toString());
      XFile? pickedImage;

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Upravit předmět'),
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
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          final pickedFile = await picker.pickImage(
                            source: ImageSource.gallery,
                          );
                          if (pickedFile != null) {
                            pickedImage = pickedFile;
                          }
                        },
                        child: const Text('Vybrat obrázek'),
                      ),
                    ],
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
                  final capacity = int.tryParse(capacityController.text) ?? 0;
                  setState(() {
                    _inventoryItems[index]['name'] = name;
                    _inventoryItems[index]['capacity'] = capacity;
                    _inventoryItems[index]['image'] = pickedImage != null
                        ? File(pickedImage!.path)
                        : _inventoryItems[index]['image'];
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
                    ? const Center(child: Text('Inventář je prázdný'))
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

// Method to show the Add Item dialog
  void _showAddItemDialog(BuildContext context) {
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
  void _showEditItemDialog(BuildContext context, int index) {
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

// Method to show the Delete confirmation dialog
  void _showDeleteConfirmationItemDialog(BuildContext context, int index) {
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

  void _showFormDialog(BuildContext context, int index) {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();

    DateTime? selectedDate;
    TimeOfDay? selectedTime;

    if (index != -1) {
      // Pre-fill the form with the person's data
      nameController.text = _submittedData[index]['name'] ?? '';
      emailController.text = _submittedData[index]['email'] ?? '';
      phoneController.text = _submittedData[index]['phone'] ?? '';
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
                // Date picker button
                Text(selectedDate == null
                    ? 'Select Date'
                    : 'Selected Date: ${DateFormat('yyyy-MM-dd').format(selectedDate!)}'),
                ElevatedButton(
                  onPressed: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2101),
                    );
                    if (pickedDate != null && pickedDate != selectedDate) {
                      setState(() {
                        selectedDate = pickedDate;
                      });
                    }
                  },
                  child: const Text('Vyber datum'),
                ),
                const SizedBox(height: 10),
                // Time picker button
                Text(selectedTime == null
                    ? 'Vyberte čas'
                    : 'Vybraný čas: ${selectedTime!.format(context)}'),
                ElevatedButton(
                  onPressed: () async {
                    TimeOfDay? pickedTime = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    if (pickedTime != null && pickedTime != selectedTime) {
                      setState(() {
                        selectedTime = pickedTime;
                      });
                    }
                  },
                  child: const Text('Vyberte čas'),
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
                final email = emailController.text;
                final phone = phoneController.text;
                final time =
                    DateFormat('yyyy-MM-dd – HH:mm:ss').format(DateTime.now());

                // If a date or time was selected, use them
                String selectedDateTime = '';
                if (selectedDate != null && selectedTime != null) {
                  final dateTime = DateTime(
                    selectedDate!.year,
                    selectedDate!.month,
                    selectedDate!.day,
                    selectedTime!.hour,
                    selectedTime!.minute,
                  );
                  selectedDateTime =
                      DateFormat('yyyy-MM-dd HH:mm').format(dateTime);
                }

                setState(() {
                  if (index == -1) {
                    _submittedData.add({
                      'name': name,
                      'email': email,
                      'phone': phone,
                      'time': time,
                      'selectedDateTime': selectedDateTime,
                    });
                  } else {
                    _submittedData[index] = {
                      'name': name,
                      'email': email,
                      'phone': phone,
                      'time': time,
                      'selectedDateTime': selectedDateTime,
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

  void _showDeleteConfirmationPacientDialog(BuildContext context, int index) {
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
                  _submittedData
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

  Widget _buildTimetable(List<Map<String, String>> appointments) {
    // Generate time slots from 7:00 AM to 6:00 PM (11 hours in total)
    final hoursInDay = List.generate(11, (index) {
      final startHour = 7 + index;
      return DateTime(
          2024, 1, 1, startHour); // Start from 7:00 AM and increment each hour
    });

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var hour in hoursInDay) _buildTimeSlotColumn(hour, appointments),
      ],
    );
  }

  Widget _buildTimeSlotColumn(
      DateTime hour, List<Map<String, String>> appointments) {
    final hourStart = DateFormat('yyyy-MM-dd HH:mm').format(hour);

    // Find all appointments for this specific hour
    final currentHourAppointments = appointments.where((person) {
      final startTime =
          DateFormat('yyyy-MM-dd HH:mm').parse(person['selectedDateTime']!);
      return startTime.hour == hour.hour;
    }).toList();

    // Return the column for this specific time slot (hour)
    return Column(
      children: [
        // Display the time at the top of each column with padding
        Padding(
          padding: const EdgeInsets.symmetric(
              vertical: 8.0), // Adjust the padding as needed
          child: Text(
            DateFormat('HH:mm').format(hour),
            style: const TextStyle(
                fontWeight: FontWeight.bold), // Optionally, make the time bold
          ),
        ),
        const SizedBox(
            height: 8), // Space between time label and the appointments
        // Display the appointments in this time slot
        for (var appointment in currentHourAppointments)
          _buildAppointmentBox(appointment),
      ],
    );
  }

  Widget _buildAppointmentBox(Map<String, String> appointment) {
    final startTime =
        DateFormat('yyyy-MM-dd HH:mm').parse(appointment['selectedDateTime']!);
    final endTime =
        startTime.add(const Duration(minutes: 20)); // 20 minutes duration

    final startMinute = startTime.minute;
    final endMinute = endTime.minute;

    // Calculate the position of the box based on the start minute
    const boxHeight = 40.0; // Height of each appointment box
    final boxOffset = (startMinute / 60) * boxHeight;

    return Padding(
      padding: const EdgeInsets.symmetric(
          vertical: 4.0), // Padding around the appointment box
      child: Container(
        margin: EdgeInsets.only(bottom: boxOffset),
        width: 60, // Width of each appointment box
        height: boxHeight, // Height of each appointment box
        color: Colors.blueAccent, // Color of the box
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              appointment['name'] ?? '',
              style: const TextStyle(color: Colors.white, fontSize: 10),
              textAlign: TextAlign.center,
            ),
            Text(
              '${DateFormat('HH:mm').format(startTime)} - ${DateFormat('HH:mm').format(endTime)}',
              style: const TextStyle(color: Colors.white, fontSize: 8),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
