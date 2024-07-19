import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../widgets/custom_dropdown.dart';
import '../widgets/custom_textfield.dart';

class UpdateDoc extends StatefulWidget {
  final String id;
  final String name;
  final String district;
  final String email;
  final String phone;
  final String gender;
  final String image;

  const UpdateDoc({
    Key? key,
    required this.id,
    required this.name,
    required this.district,
    required this.email,
    required this.phone,
    required this.gender,
    required this.image,
  }) : super(key: key);

  @override
  State<UpdateDoc> createState() => _UpdateDocState();
}

class _UpdateDocState extends State<UpdateDoc> {
  File? _image;
  final picker = ImagePicker();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  String? selectedDistrict;
  String? selectedGender;

  @override
  void initState() {
    super.initState();
    nameController.text = widget.name;
    emailController.text = widget.email;
    phoneController.text = widget.phone;
    selectedDistrict = widget.district;
    selectedGender = widget.gender;
    _initializeImage();
  }

  Future<void> _initializeImage() async {
    if (widget.image.isNotEmpty) {
      setState(() {
        _image = File(widget.image);
      });
    }
  }

  Future<void> _pickImage() async {
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        _image = File(pickedImage.path);
      });
    }
  }

  Future<String> _uploadImage(File image) async {
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

  void _updateDoctor() async {
    String imageUrl = widget.image;
    if (_image != null && _image!.path != widget.image) {
      imageUrl = await _uploadImage(_image!);
    }

    final data = {
      'Name': nameController.text,
      'Phone': phoneController.text,
      'Email': emailController.text,
      'District': selectedDistrict,
      'Gender': selectedGender,
      'Image': imageUrl,
    };


    FirebaseFirestore.instance.collection('admins').doc(widget.id).update(data).then((_) {
      Navigator.pop(context, true);
    });
  }

  void _deleteDoctor() {
    FirebaseFirestore.instance.collection('admins').doc(widget.id).delete().then((_) {
      Navigator.pop(context, true);
    });
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
          "Edit Doctor",
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _deleteDoctor,
            icon: const Icon(Icons.delete),
            color: Colors.red,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 30),
            Center(
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  CircleAvatar(
                    backgroundImage: _image != null
                        ? FileImage(_image!)
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
                        onPressed: _pickImage,
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
                items: const [
                  'Malappuram',
                  'Kozhikode',
                  'Wayanad',
                  'Kannur',
                  'Kasaragod',
                ],
                onChanged: (value) {
                  setState(() {
                    selectedDistrict = value;
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
                    selectedGender = value;
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
                  minimumSize: MaterialStateProperty.all(
                    Size(screenWidth * 0.8, 50), // Set width to 80% of screen width
                  ),
                ),
                onPressed: _updateDoctor,
                child: const Text(
                  "Save",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
