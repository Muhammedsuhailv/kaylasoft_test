import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:image_picker/image_picker.dart';
import '../widgets/custom_dropdown.dart';
import '../widgets/custom_textfield.dart';

class AddDoc extends StatefulWidget {
  const AddDoc({Key? key}) : super(key: key);

  @override
  State<AddDoc> createState() => _AddDocState();
}

class _AddDocState extends State<AddDoc> {
  String selectedGender = 'Male';
  String selectedDistrict = 'Malappuram';
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  File? _imageFile;

  final CollectionReference admins = FirebaseFirestore.instance.collection('admins');

  Future<String> uploadImage(File image) async {
    try {
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference reference = FirebaseStorage.instance.ref().child('images/$fileName');
      UploadTask uploadTask = reference.putFile(image);
      TaskSnapshot storageTaskSnapshot = await uploadTask;
      return await storageTaskSnapshot.ref.getDownloadURL();
    } catch (e) {
      print('Error uploading image: $e');
      return '';
    }
  }

  Future<void> _pickImage(BuildContext context) async {
    final ImagePicker _picker = ImagePicker();
    try {
      final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      print("Error picking image: $e");
    }
  }

  void addDoctor(String? imageUrl) {
    final data = {
      'Name': nameController.text,
      'Email': emailController.text,
      'Phone': phoneController.text,
      'Image': imageUrl ?? '',
      'District': selectedDistrict,
      'Gender': selectedGender,
    };
    admins.add(data);
  }

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back_ios_new),
        ),
        title: const Text(
          "Add Doctor",
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.delete),
            color: Colors.red,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Form(
          key: formKey,
          child: Column(
            children: [
              const SizedBox(height: 30),
              Center(
                child:
                //     ? Stack(
                //   children: [
                //     CircleAvatar(
                //       radius: 50,
                //       child: Positioned(
                //         bottom: 0,
                //         right: 0,
                //         child: IconButton(
                //           style: ButtonStyle(
                //             backgroundColor: MaterialStateProperty.all(HexColor("54E70F")),
                //           ),
                //           onPressed: () => _pickImage(context),
                //           icon: const Icon(
                //             Icons.edit,
                //             color: Colors.white,
                //           ),
                //         ),
                //       ),
                //     ),
                //   ],
                // )
                //     : Stack(
                //   children: [
                //     CircleAvatar(
                //       backgroundColor: Colors.cyan,
                //       radius: 50,
                //       child: ClipOval(
                //         child: Container(
                //           height: 105,
                //           width: 105,
                //           decoration: BoxDecoration(
                //             borderRadius: BorderRadius.circular(104),
                //           ),
                //           child: Image.file(_imageFile!, fit: BoxFit.cover),
                //         ),
                //       ),
                //     ),
                //     Positioned(
                //       bottom: 0,
                //       right: 0,
                //       child: IconButton(
                //         style: ButtonStyle(
                //           backgroundColor: MaterialStateProperty.all(HexColor("54E70F")),
                //         ),
                //         onPressed: () => _pickImage(context),
                //         icon: const Icon(
                //           Icons.edit,
                //           color: Colors.white,
                //         ),
                //       ),
                //     ),
                //   ],
                // ),

               Stack(
                  clipBehavior: Clip.none,
                  children: [
                    CircleAvatar(
                      backgroundImage: _imageFile != null
                          ? FileImage(_imageFile!)
                          : const AssetImage("asset/profile.png") as ImageProvider,
                      radius: 60,
                    ),
                    Positioned(
                      right: -5,
                      bottom: -3,
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: const Color(0xff019744),
                        ),
                        child: IconButton(
                                  onPressed: () => _pickImage(context),
                          color: Colors.white,
                          icon: const Icon(Icons.edit),
                          iconSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: CustomTextfield(
                  cntrl: nameController,
                  label: "Full Name",
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: CustomDropdown(
                  hint: "District",
                  items: const ['Malappuram', 'Kozhikode', 'Wayanad', 'Kannur', 'Kasaragod'],
                  onChanged: (value) {
                    setState(() {
                      selectedDistrict = value!;
                    });
                  },
                  value: selectedDistrict,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: CustomTextfield(
                  cntrl: emailController,
                  label: "Email",
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: CustomTextfield(
                  cntrl: phoneController,
                  label: "Phone Number",
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: CustomDropdown(
                  hint: "Gender",
                  items: const ['Male', 'Female', 'Other'],
                  onChanged: (value) {
                    setState(() {
                      selectedGender = value!;
                    });
                  },
                  value: selectedGender,
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(const Color(0xff019744)),
                    minimumSize: MaterialStateProperty.all(Size(screenWidth * 0.8, 50)), // Adjust width as needed
                  ),
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      String? imageUrl;
                      if (_imageFile != null) {
                        imageUrl = await uploadImage(_imageFile!);
                      }
                      addDoctor(imageUrl);
                      Navigator.pop(context);
                      print("Doctor added successfully!");
                    } else {
                      if (nameController.text.isEmpty) {
                        print("Full Name is required!");
                      }

                      if (emailController.text.isEmpty) {
                        print("Email is required!");
                      }

                      if (phoneController.text.isEmpty) {
                        print("Phone Number is required!");
                      }
                    }
                  },
                  child: const Text(
                    "Save",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
