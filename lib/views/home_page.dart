import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'addPage.dart';
import 'update_doctor.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? selectedGender = 'Gender';
  String? selectedDistrict = 'District';

  @override
  Widget build(BuildContext context) {
    CollectionReference collectionReference = FirebaseFirestore.instance.collection("admins");
    var screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          "Doctors",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        actions: [
          SizedBox(
            width: screenWidth * 0.3,
            child: DropdownButtonFormField<String>(
              decoration: InputDecoration(
                hintText: 'Gender',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                isDense: true,
              ),
              value: selectedGender,
              onChanged: (String? value) {
                setState(() {
                  selectedGender = value;
                });
              },
              items: ['All', 'Male', 'Female', 'Other'].map((String item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(
                    item,
                    style: const TextStyle(fontSize: 12),
                  ),
                );
              }).toList(),
            ),
          ),
          SizedBox(
            width: screenWidth * 0.37,
            child: DropdownButtonFormField<String>(
              decoration: InputDecoration(
                hintText: 'District',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                isDense: true,
              ),
              value: selectedDistrict,
              onChanged: (String? value) {
                setState(() {
                  selectedDistrict = value;
                });
              },
              items: ['All', 'Malappuram', 'Kozhikode', 'Wayanad', 'Kannur', 'Kasaragod']
                  .map((String item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(
                    item,
                    style: const TextStyle(fontSize: 12),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          StreamBuilder<QuerySnapshot>(
            stream: (selectedGender == 'All' && selectedDistrict == 'All')
                ? collectionReference.snapshots()
                : (selectedGender == 'All'
                ? collectionReference.where('District', isEqualTo: selectedDistrict).snapshots()
                : (selectedDistrict == 'All'
                ? collectionReference.where('Gender', isEqualTo: selectedGender).snapshots()
                : collectionReference
                .where('Gender', isEqualTo: selectedGender)
                .where('District', isEqualTo: selectedDistrict)
                .snapshots())),
            builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              return Expanded(
                child: ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var doc = snapshot.data!.docs[index];
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Card(
                        child: Container(
                          height: 100,
                          width: screenWidth,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  doc['Image'] != null
                                      ? Image.network(
                                    doc['Image'],
                                    height: 80,
                                    width: 80,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Placeholder(
                                        fallbackHeight: 80,
                                        fallbackWidth: 80,
                                        color: Colors.grey,
                                        child: Image.asset("asset/istockphoto-610003972-612x612.jpg"),
                                      );
                                    },
                                  )
                                      : const Placeholder(
                                    fallbackHeight: 80,
                                    fallbackWidth: 80,
                                  ),
                                  const SizedBox(width: 15),
                                  Expanded(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(height: 10),
                                        Text(
                                          doc['Name'] ?? 'No Name',
                                          style: const TextStyle(fontWeight: FontWeight.w700),
                                        ),
                                        Text(
                                          doc['Email'] ?? 'No Email',
                                          style: const TextStyle(fontSize: 10),
                                        ),
                                        Text(
                                          doc['District'] ?? 'No District',
                                          style: const TextStyle(fontSize: 10),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 30.0),
                                    child: InkWell(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => UpdateDoc(
                                              id: doc.id,
                                              name: doc['Name'] ?? '',
                                              district: doc['District'] ?? '',
                                              email: doc['Email'] ?? '',
                                              phone: doc['Phone'] ?? '',
                                              gender: doc['Gender'] ?? '',
                                              image: doc['Image'] ?? '',
                                            ),
                                          ),
                                        ).then((result) {
                                          if (result != null && result) {
                                            // Trigger UI refresh if necessary
                                          }
                                        });
                                      },
                                      child: Container(
                                        width: 65,
                                        height: 20,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(5),
                                          color: const Color(0xff019744),
                                        ),
                                        child: const Center(
                                          child: Text(
                                            "Edit Profile",
                                            style: TextStyle(fontSize: 10, color: Colors.white),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xff019744),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50),
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddDoc()),
          );
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
