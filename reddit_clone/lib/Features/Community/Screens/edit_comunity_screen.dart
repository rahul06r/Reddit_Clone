import 'dart:typed_data';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone/Core/Constant/constants.dart';
import 'package:reddit_clone/Core/common/errorText.dart';
import 'package:reddit_clone/Core/common/loader.dart';
import 'package:reddit_clone/Features/Community/Controllers/community_controller.dart';
import 'package:reddit_clone/Models/community_model.dart';
import 'package:reddit_clone/Responsive%20Materials/responsive_W.dart';

import 'package:reddit_clone/themes/pallete.dart';
import 'dart:io';

import '../../../Core/utils.dart';

class EditCommunityScreen extends ConsumerStatefulWidget {
  final String name;
  const EditCommunityScreen({super.key, required this.name});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _EditCommunityScreenState();
}

class _EditCommunityScreenState extends ConsumerState<EditCommunityScreen> {
  File? bannerFile;
  File? profileImage;
  Uint8List? bannerWebFile;
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

  //
  // svaing commuinty
  void saves(Community community) {
    ref.read(communityConProvider.notifier).editCommunity(
          profileFile: profileImage,
          bannerFile: bannerFile,
          context: context,
          community: community,
          bannerWebFile: bannerWebFile,
          profileWebFile: profileWebFile,
        );
  }

  @override
  Widget build(BuildContext context) {
    final currentTheme = ref.watch(themeNotifierProvider);
    final isLoading = ref.watch(communityConProvider);
    return ref.watch(getCommmuintyByNameProvider(widget.name)).when(
        data: (data) => Scaffold(
              // check for background collor
              // backgroundColor: Pallete.darkModeAppTheme.colorScheme.background,
              backgroundColor: currentTheme.backgroundColor,
              appBar: AppBar(
                title: const Text("Edit Community"),
                actions: [
                  TextButton(
                    onPressed: () => saves(data),
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
                                          borderRadius:
                                              BorderRadius.circular(10),
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
                                                    : Image.network(
                                                        data.banner),
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
                                                  MemoryImage(profileWebFile!),
                                              radius: 32,
                                            )
                                          : profileImage != null
                                              ? CircleAvatar(
                                                  backgroundImage:
                                                      FileImage(profileImage!),
                                                  radius: 32,
                                                )
                                              : CircleAvatar(
                                                  backgroundImage:
                                                      NetworkImage(data.avatar),
                                                  radius: 32,
                                                ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
            ),
        error: ((error, stackTrace) =>
            ErrorText(errorMessage: error.toString())),
        loading: () => const Loader());
  }
}
