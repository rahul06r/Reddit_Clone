import 'dart:io';
import 'dart:typed_data';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone/Features/Auth/Controllers/auth_controller.dart';
import 'package:reddit_clone/Features/user_profile_Screen/Controller/userProfile_controller.dart';
import 'package:reddit_clone/Responsive%20Materials/responsive_W.dart';

import '../../../Core/Constant/constants.dart';
import '../../../Core/common/errorText.dart';
import '../../../Core/common/loader.dart';
import '../../../Core/utils.dart';
import '../../../themes/pallete.dart';

class EditProfileSCreen extends ConsumerStatefulWidget {
  final String uid;
  const EditProfileSCreen({
    super.key,
    required this.uid,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _EditProfileSCreenState();
}

class _EditProfileSCreenState extends ConsumerState<EditProfileSCreen> {
  late TextEditingController textEditingController;
  @override
  void initState() {
    super.initState();
    textEditingController =
        TextEditingController(text: ref.read(userProvider)!.name);
  }

  @override
  void dispose() {
    super.dispose();
    textEditingController.dispose();
  }

  File? bannerFile;
  Uint8List? bannerWebFile;
  File? profileImage;
  Uint8List? profileWebFile;
  Future<void> selectedBannerFile() async {
    final res = await pickImage();
    if (res != null) {
      if (kIsWeb) {
        setState(() {
          bannerWebFile = res.files.first.bytes;
        });
      } else {
        setState(() {
          bannerFile = File(res.files.first.path!);
        });
      }
    }
  }

  //
  Future<void> selectedProfileFile() async {
    final res = await pickImage();
    if (res != null) {
      if (kIsWeb) {
        setState(() {
          profileWebFile = res.files.first.bytes;
        });
      } else {
        setState(() {
          profileImage = File(res.files.first.path!);
        });
      }
    }
  }

  // save
  void save() {
    ref.read(userProfileControlllerProvider.notifier).editProfile(
          profileFile: profileImage,
          bannerFile: bannerFile,
          context: context,
          name: textEditingController.text.trim(),
          bannerWebFile: bannerWebFile,
          profileWebFile: profileWebFile,
        );
  }

  @override
  Widget build(BuildContext context) {
    // final isLoading = ref.watch(communityConProvider);
    final currentTheme = ref.watch(themeNotifierProvider);

    final isLoading = ref.watch(userProfileControlllerProvider);
    return ref.watch(getUserDataProvider(widget.uid)).when(
          data: (data) => Scaffold(
            // check for background collor
            // backgroundColor: Pallete.darkModeAppTheme.colorScheme.background,
            backgroundColor: currentTheme.backgroundColor,
            appBar: AppBar(
              title: const Text("Edit Profile"),
              actions: [
                TextButton(
                  onPressed: save,
                  child: const Text(
                    "Save",
                  ),
                ),
              ],
            ),
            body: isLoading
                ? const Loader()
                : ResponsiveW(
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        children: [
                          SizedBox(
                            height: 225,
                            child: Stack(
                              children: [
                                GestureDetector(
                                  onTap: selectedBannerFile,
                                  child: DottedBorder(
                                    borderType: BorderType.RRect,
                                    radius: const Radius.circular(10),
                                    dashPattern: const [10, 4],
                                    strokeCap: StrokeCap.round,
                                    color: currentTheme
                                        .textTheme.bodyMedium!.color!,
                                    child: Container(
                                      width: double.infinity,
                                      height: 200,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: bannerWebFile != null
                                          ? Image.memory(bannerWebFile!)
                                          : bannerFile != null
                                              ? Image.file(bannerFile!)
                                              : data.banner.isEmpty ||
                                                      data.banner ==
                                                          Constants
                                                              .bannerDefault
                                                  ? const Center(
                                                      child: Icon(
                                                          Icons
                                                              .camera_alt_outlined,
                                                          size: 40),
                                                    )
                                                  : Image.network(data.banner),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  left: 15,
                                  bottom: 0,
                                  child: GestureDetector(
                                    onTap: selectedProfileFile,
                                    child: profileWebFile != null
                                        ? CircleAvatar(
                                            backgroundImage:
                                                MemoryImage(bannerWebFile!),
                                            radius: 32,
                                          )
                                        : profileImage != null
                                            ? CircleAvatar(
                                                backgroundImage:
                                                    FileImage(profileImage!),
                                                radius: 32,
                                              )
                                            : CircleAvatar(
                                                backgroundImage: NetworkImage(
                                                    data.profilePic),
                                                radius: 32,
                                              ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          TextField(
                            controller: textEditingController,
                            decoration: InputDecoration(
                              filled: true,
                              hintText: 'Name',
                              focusedBorder: OutlineInputBorder(
                                borderSide:
                                    const BorderSide(color: Colors.blue),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.all(18),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
          ),
          error: ((error, stackTrace) =>
              ErrorText(errorMessage: error.toString())),
          loading: () => const Loader(),
        );
  }
}
