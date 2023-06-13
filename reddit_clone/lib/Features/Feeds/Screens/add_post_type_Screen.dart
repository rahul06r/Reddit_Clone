import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone/Core/common/errorText.dart';
import 'package:reddit_clone/Core/common/loader.dart';
import 'package:reddit_clone/Features/Community/Controllers/community_controller.dart';
import 'package:reddit_clone/Features/Post/Controller/post_controller.dart';
import 'package:reddit_clone/Responsive%20Materials/responsive_W.dart';
import 'package:reddit_clone/themes/pallete.dart';

import '../../../Core/utils.dart';
import '../../../Models/community_model.dart';

class AddPostTypeScreen extends ConsumerStatefulWidget {
  final String type;
  const AddPostTypeScreen({
    super.key,
    required this.type,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _AddPostTypeScreenState();
}

class _AddPostTypeScreenState extends ConsumerState<AddPostTypeScreen> {
  final titleController = TextEditingController();
  final descController = TextEditingController();
  final linkController = TextEditingController();
  Community? selectedCommunity;

  List<Community> communites = [];

  @override
  void dispose() {
    super.dispose();
    titleController.dispose();
    descController.dispose();
    linkController.dispose();
  }

  //
  File? bannerFile;
  Uint8List? bannerWebfile;
  Future<void> selectedBannerFile() async {
    final res = await pickImage();
    if (res != null) {
      if (kIsWeb) {
        setState(() {
          bannerWebfile = res.files.first.bytes;
        });
      }
      setState(() {
        bannerFile = File(res.files.first.path!);
      });
    }
  }

  //
  void sharePost() {
    if (widget.type == 'image' &&
        titleController.text.isNotEmpty &&
        (bannerFile != null || bannerWebfile != null)) {
      ref.read(postConProvider.notifier).shareImagePost(
          webFile: bannerWebfile,
          context: context,
          titletext: titleController.text.trim(),
          selectedCommunity: selectedCommunity ?? communites[0],
          image: bannerFile);
    } else if (widget.type == 'text' && titleController.text.isNotEmpty) {
      ref.read(postConProvider.notifier).shareTextPost(
            context: context,
            titletext: titleController.text.trim(),
            selectedCommunity: selectedCommunity ?? communites[0],
            description: descController.text,
          );
    } else if (widget.type == 'link' &&
        titleController.text.isNotEmpty &&
        linkController.text.isNotEmpty) {
      ref.read(postConProvider.notifier).shareLinkPost(
            context: context,
            titletext: titleController.text.trim(),
            selectedCommunity: selectedCommunity ?? communites[0],
            link: linkController.text.trim(),
          );
    } else {
      showsnackBars(
        context,
        'Please Enter all fields',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentTheme = ref.watch(themeNotifierProvider);
    final isTypedImage = widget.type == 'image';
    final isTypedLink = widget.type == 'link';
    final isTypedtext = widget.type == 'text';
    final isloading = ref.watch(postConProvider);
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text('Post ${widget.type}'),
          actions: [
            TextButton(
              onPressed: sharePost,
              child: const Text('Share'),
            ),
          ],
        ),
        body: isloading
            ? const Loader()
            : ResponsiveW(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      TextField(
                        controller: titleController,
                        decoration: const InputDecoration(
                          filled: true,
                          hintText: 'Enter Text Here',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(18),
                        ),
                        maxLength: 30,
                        // autocorrect: true,
                      ),
                      const SizedBox(height: 20),
                      if (isTypedImage)
                        GestureDetector(
                          onTap: selectedBannerFile,
                          child: DottedBorder(
                            borderType: BorderType.RRect,
                            radius: const Radius.circular(10),
                            dashPattern: const [10, 4],
                            strokeCap: StrokeCap.round,
                            color: currentTheme.textTheme.bodyMedium!.color!,
                            child: Container(
                                width: double.infinity,
                                height: 200,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: bannerWebfile != null
                                    ? Image.memory(bannerWebfile!)
                                    : bannerFile != null
                                        ? Image.file(bannerFile!)
                                        : const Center(
                                            child: Icon(
                                                Icons.camera_alt_outlined,
                                                size: 40),
                                          )),
                          ),
                        ),

                      //

                      //

                      //
                      if (isTypedtext)
                        TextField(
                          controller: descController,
                          decoration: const InputDecoration(
                            filled: true,
                            hintText: 'Enter Description Here',
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.all(18),
                          ),
                          maxLines: 5,
                        ),

                      //
                      //
                      if (isTypedLink)
                        TextField(
                          controller: linkController,
                          decoration: const InputDecoration(
                            filled: true,
                            hintText: 'Enter Link Here',
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.all(18),
                          ),
                        ),

                      const SizedBox(height: 20),
                      const Align(
                          alignment: Alignment.topLeft,
                          child: Text("Select Community")),

                      //
                      ref.watch(userCommunityProvider).when(
                            data: (data) {
                              communites = data;

                              if (data.isEmpty) {
                                return const SizedBox();
                              }
                              return DropdownButton(
                                value: selectedCommunity ?? data[0],
                                items: data
                                    .map((e) => DropdownMenuItem(
                                        value: e, child: Text(e.name)))
                                    .toList(),
                                onChanged: (val) {
                                  setState(() {
                                    selectedCommunity = val;
                                  });
                                },
                              );
                            },
                            error: (error, stackTrace) =>
                                ErrorText(errorMessage: error.toString()),
                            loading: () => const Loader(),
                          )
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
