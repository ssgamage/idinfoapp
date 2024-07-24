import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/backgrounds/ellipse-home.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                flex: 7,
                child: Container(
                  alignment: Alignment.topCenter,
                  padding: const EdgeInsets.only(top: 170),
                  child: Image.asset('assets/images/backgrounds/logo-text.png',
                      width: 220),
                ),
              ),
              Expanded(
                flex: 17, //main sector
                child: SingleChildScrollView(
                  child: Container(
                    alignment: Alignment.topCenter,
                    padding: const EdgeInsets.only(top: 50),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Enter a NIC Number',
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 5),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 30),
                          child: Center(
                            child: Text(
                              'E.g: 123456789V, 123456789X, \n         123456789, 201234506789',
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.black,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        // form method
                        NicInfoForm(),
                        //SizedBox(height: 5),
                        //NicInormations(),
                        SizedBox(height: 5),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: SingleChildScrollView(
                  child: Container(
                    alignment: Alignment.topCenter,
                    padding: const EdgeInsets.only(top: 0),
                    child: GestureDetector(
                      onTap: () {
                        _launchEmail('szxcreations@gmail.com');
                      },
                      child: RichText(
                        text: const TextSpan(
                          children: [
                            TextSpan(
                              text: "False details or a Bug?",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                              ),
                            ),
                            TextSpan(
                              text: ' Report Here',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.blue,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        resizeToAvoidBottomInset: false,
      ),
    );
  }

  _launchEmail(String email) async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: email,
      query: Uri.encodeComponent('subject=Feedback:SL-NIC-INFO-APP'),
    );

    if (await canLaunchUrl(emailLaunchUri)) {
      await launchUrl(emailLaunchUri);
    } else {
      throw 'Could not launch $emailLaunchUri';
    }
  }
}

class NicInfoForm extends StatefulWidget {
  const NicInfoForm({super.key});

  @override
  _NicInfoFormState createState() => _NicInfoFormState();
}

class _NicInfoFormState extends State<NicInfoForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final _nicController = TextEditingController();

  Map<String, String> _nicDetails = {};

  @override
  void dispose() {
    _nicController.dispose();
    super.dispose();
  }

  String? _nic;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Form(
          key: _formKey,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 55),
                child: TextFormField(
                  controller: _nicController,
                  decoration: InputDecoration(
                    labelText: 'NIC Number',
                    prefixIcon: const Icon(Icons.account_box_rounded),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter NIC to continue';
                    }

                    // Regular expressions for the three valid formats
                    final nicFormat1 = RegExp(r'^\d{9}$');
                    final nicFormat2 = RegExp(r'^\d{9}[VvXx]$');
                    final nicFormat3 = RegExp(r'^\d{12}$');

                    if (!nicFormat1.hasMatch(value) &&
                        !nicFormat2.hasMatch(value) &&
                        !nicFormat3.hasMatch(value)) {
                      return 'Please enter a valid NIC';
                    }

                    return null;
                  },
                  onSaved: (value) {
                    _nic = value;
                  },
                ),
              ),
              const SizedBox(height: 20),
              //Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 55),
                child: ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: const Color.fromARGB(255, 23, 1, 147),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: const Text(
                    'Show Details',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        if (_nicDetails.isNotEmpty) NicInformations(nicDetails: _nicDetails),
      ],
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        _nicDetails = _calculateNicDetails(_nic!);
      });
      // Clean text field
      _nicController.clear();
    }
  }

  Map<String, String> _calculateNicDetails(String nic) {
    final Map<String, String> details = {};
    final now = DateTime.now();

    if (nic.length == 10 || nic.length == 9) {
      // Old NIC format
      final birthYear = int.parse('19${nic.substring(0, 2)}');
      int dayOfYear = int.parse(nic.substring(2, 5));

      final gender = dayOfYear > 500 ? 'Female' : 'Male';
      if (dayOfYear > 500) dayOfYear -= 500;

      final birthDate = _getDateFromDayOfYear(birthYear, dayOfYear);
      final age = _calculateAge(birthDate, now);

      details['NIC Format'] = 'OLD NIC';
      details['Birth Year'] = birthYear.toString();
      details['Birth Date'] = DateFormat('yyyy-MM-dd').format(birthDate);
      details['Gender'] = gender;
      details['Voting Status'] =
          nic[9].toUpperCase() == 'V' ? 'Voting' : 'Non-Voting';
      details['Serial Number'] = nic.substring(5, 8);
      details['Check Digit'] = nic[8];
      details['Age'] =
          '${age.years} years, ${age.months} months, ${age.days} days';
    } else if (nic.length == 12) {
      // New NIC format
      final birthYear = int.parse(nic.substring(0, 4));
      int dayOfYear = int.parse(nic.substring(4, 7));

      final gender = dayOfYear > 500 ? 'Female' : 'Male';
      if (dayOfYear > 500) dayOfYear -= 500;

      final birthDate = _getDateFromDayOfYear(birthYear, dayOfYear);
      final age = _calculateAge(birthDate, now);

      details['NIC Format'] = 'NEW NIC';
      details['Birth Year'] = birthYear.toString();
      details['Birth Date'] = DateFormat('yyyy-MM-dd').format(birthDate);
      details['Gender'] = gender;
      details['Voting Status'] = 'Unknown';
      details['Serial Number'] = nic.substring(7, 10);
      details['Check Digit'] = nic[11];
      details['Age'] =
          '${age.years} years, ${age.months} months, ${age.days} days';
    }

    return details;
  }

  DateTime _getDateFromDayOfYear(int year, int dayOfYear) {
    if (year % 4 == 0 && (year % 100 != 0 || year % 400 == 0)) {
      return DateTime(year, 1, 1).add(Duration(days: dayOfYear - 1));
    } else {
      return DateTime(year, 1, 1).add(Duration(days: dayOfYear - 2));
    }
  }

  _Age _calculateAge(DateTime birthDate, DateTime now) {
    int years = now.year - birthDate.year;
    int months = now.month - birthDate.month;
    int days = now.day - birthDate.day;

    if (days < 0) {
      final prevMonth = DateTime(now.year, now.month - 1, birthDate.day);
      days = now.difference(prevMonth).inDays;
      months -= 1;
    }

    if (months < 0) {
      months += 12;
      years -= 1;
    }

    return _Age(years: years, months: months, days: days);
  }
}

class NicInformations extends StatelessWidget {
  final Map<String, String> nicDetails;

  const NicInformations({required this.nicDetails, super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20), // Adjusted padding
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white, // Background color of the box
          borderRadius: BorderRadius.circular(10), // Rounded corners
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2), // Shadow color
              spreadRadius: 2, // Spread radius
              blurRadius: 5, // Blur radius
              offset: const Offset(0, 3), // Shadow offset
            ),
          ],
        ),
        padding: const EdgeInsets.all(16), // Padding inside the box
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: nicDetails.entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: RichText(
                text: TextSpan(
                  style: const TextStyle(fontSize: 16, color: Colors.black),
                  children: [
                    TextSpan(
                      text: '${entry.key}: ', // Title
                      style: const TextStyle(
                        fontWeight: FontWeight.bold, // Make title bold
                        color: Colors.black, // Title color
                      ),
                    ),
                    TextSpan(
                      text: entry.value, // Value
                      style: const TextStyle(
                        fontWeight:
                            FontWeight.normal, // Normal weight for value
                        color: Colors.black, // Value color
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _Age {
  final int years;
  final int months;
  final int days;

  _Age({required this.years, required this.months, required this.days});
}
