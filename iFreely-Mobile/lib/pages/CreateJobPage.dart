import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flut/bloc/create_job/create_job_bloc.dart';
import 'package:flut/consts/routes.dart';
import 'package:flut/models/job_model.dart';
import 'package:flut/models/user_model.dart';
import 'package:flut/repos/auth_repo.dart';
import 'package:flut/repos/job_creation_repo.dart';
import 'package:flut/ui/feed_job_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:mime/mime.dart';

class CreateJobPage extends StatefulWidget {
  const CreateJobPage({super.key});

  @override
  State<CreateJobPage> createState() => _CreateJobPageState();
}

class _CreateJobPageState extends State<CreateJobPage> {
  final ScrollController _scrollController = ScrollController();
  final PageController _pageController = PageController();
  final TextEditingController _dateController = TextEditingController();
  final JobModel _jobModel = JobModel(
    job_title: "",
    experience: "",
    job_size: "",
    description: "",
    deadline: "",
    wilaya: "",
    modality: "",
    frequency: "",
    payment_structure: "",
    rate: 0,
    payment_method: "",
    boost: "",
    files: [],
    username: "",
  );


  @override
  void initState() {
    super.initState();
    _jobModel.username = context.read<AuthRepo>().user_model!.firstName + " " + context.read<AuthRepo>().user_model!.lastName; 
  }


  final job_size = ["Small", "Medium", "Large"];
  final payment_structure = [
    "By mile stone",
    "By project",
  ];

  int stage = 0;
  List<String> _uploadedFilesTypes = [];
  List<File> _files = [];
  @override
  void dispose() {
    _scrollController.dispose();
    _pageController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  void _nextStage() {
    stage++;
    setState(() {
      _active = false;
    });

    _pageController.animateToPage(stage,
        duration: Duration(milliseconds: 500), curve: Curves.linear);
    _scrollController.animateTo(
        (stage) * (MediaQuery.of(context).size.width - 65) * 0.45,
        duration: Duration(milliseconds: 500),
        curve: Curves.linear);
  }

  void _prevStage(int stage) {
    _pageController.animateToPage(stage,
        duration: Duration(milliseconds: 500), curve: Curves.linear);
    _scrollController.animateTo(
        (stage) * (MediaQuery.of(context).size.width - 65) * 0.45,
        duration: Duration(milliseconds: 500),
        curve: Curves.linear);
    _finish_stage(stage);
  }

  void update_job_title(val) {
    if (val != null) {
      _jobModel.job_title = val;
    }
  }

  void update_experience(val) {
    if (val != null) {
      _jobModel.experience = val;
    }
  }

  void update_job_size(val) {
    if (val != null) {
      _jobModel.job_size = val;
    }
  }

  void update_description(val) {
    if (val != null) {
      _jobModel.description = val;
    }
  }

  void update_deadline(val) {
    if (val != null) {
      _dateController.text = val;
    }

    _jobModel.deadline = val;
  }

  void update_wilaya(val) {
    if (val != null) {
      _jobModel.wilaya = val;
    }
  }

  void update_modality(val) {
    if (val != null) {
      _jobModel.modality = val;
    }
  }

  void update_frequency(val) {
    if (val != null) {
      _jobModel.frequency = val;
    }
  }

  void update_payment_structure(val) {
    if (val != null) {
      _jobModel.payment_structure = val;
    }
  }

  void update_rate(val) {
    try {
    if (val != null ) {
      _jobModel.rate = int.parse(val);
    }
    } catch (e) {
      print(e);
      _jobModel.rate = 0;
    }
  }

  void update_payment_method(val) {
    if (val != null) {
      _jobModel.payment_method = val;
    }
  }

  void update_boost(val) {
    if (val != null) {
      _jobModel.boost = val;
    }
  }

  void update_files(val) {
    if (val != null) {
      _jobModel.files = val;
    }
  }

  bool _active = false;
  void _finish_stage(int stage) {
    if (stage == 0) {
      if (_jobModel.job_title.isNotEmpty &&
          _jobModel.experience.isNotEmpty &&
          _jobModel.description.isNotEmpty &&
          _jobModel.description.length >= 100) {
        setState(() {
          _active = true;
        });
      } else {
        setState(() {
          _active = false;
        });
      }
    } else if (stage == 1) {
      if (_jobModel.deadline.isNotEmpty && _jobModel.frequency.isNotEmpty) {
        setState(() {
          _active = true;
        });
      } else {
        setState(() {
          _active = false;
        });
      }
    } else if (stage == 2) {
      if (_jobModel.payment_structure.isNotEmpty &&
          _jobModel.payment_method.isNotEmpty) {
        setState(() {
          _active = true;
        });
      } else {
        setState(() {
          _active = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar(),
      body: SingleChildScrollView(
        child: BlocProvider(
          create: (context) => CreateJobBloc(context.read<JobCreationRepo>()),
          child: BlocBuilder<CreateJobBloc, CreateJobState>(
            builder: (context, state) {
              return PopScope(
                onPopInvoked: (didPop) {
                  if (!didPop) {
                    context.read<CreateJobBloc>().add(SetStage(stage - 1));
                    setState(() {
                      stage--;
                    });
                    _prevStage(stage);
                  }
                },
                canPop: stage == 0,
                child: Column(
                  children: [
                    SizedBox(
                      height: 20,
                    ),
                    _textHeader(),
                    SizedBox(
                      height: 20,
                    ),
                    _progressBar(),
                    SizedBox(
                      height: 10,
                    ),
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: 0,
                        minWidth: 0,
                        maxWidth: MediaQuery.of(context).size.width,
                        maxHeight: MediaQuery.of(context).size.height - 120,
                      ),
                      child: PageView.builder(
                        physics: NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          return [
                            _firstStage(context),
                            _secondStage(context),
                            _thirdStage(context),
                            _fourthStage(context),
                            _fifthStage(context, state),
                          ][index];
                        },
                        controller: _pageController,
                        itemCount: 5,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Center _textHeader() {
    return Center(
        child: Text(
      "Describe the job you need",
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    ));
  }

  AppBar _appBar() {
    return AppBar(
      surfaceTintColor: Colors.white,
      title: Text(
        "Create Job",
        style: TextStyle(fontSize: 14),
      ),
      leading: Visibility(
        visible: true,
        child: TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text("<", style: TextStyle(fontSize: 20, color: Colors.grey)),
        ),
      ),
      centerTitle: true,
      actions: [IconButton(onPressed: () {}, icon: Icon(Icons.more_vert))],
    );
  }

  SingleChildScrollView _progressBar() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: NeverScrollableScrollPhysics(),
      controller: _scrollController,
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 3,
        height: 100,
        child: Stack(
          children: [
            _divider(1, stage >= 1),
            ProgressSpecifier(
              index: 1,
              label: "General info",
              active: true,
            ),
            _divider(2, stage >= 2),
            ProgressSpecifier(
              index: 2,
              label: "Time",
              active: stage >= 1,
            ),
            _divider(3, stage >= 3),
            ProgressSpecifier(
              index: 3,
              label: "Rate",
              active: stage >= 2,
            ),
            _divider(4, stage >= 4),
            ProgressSpecifier(
              index: 4,
              label: "Upload Files",
              active: stage >= 3,
            ),
            ProgressSpecifier(
              index: 5,
              label: "Review & Post",
              active: stage >= 4,
            ),
          ],
        ),
      ),
    );
  }

  Positioned _divider(int index, bool active) {
    return Positioned(
      top: 25,
      left: (MediaQuery.of(context).size.width) / 2 +
          (index - 1) * (MediaQuery.of(context).size.width - 65) * 0.45 +
          16,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 500),
        curve: Curves.linear,
        height: 2,
        width: (MediaQuery.of(context).size.width) * 0.45 - 50,
        color: active ? Color(0xFF7360DF) : Colors.grey,
      ),
    );
  }

  Widget _firstStage(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _textField(
            "Job Title",
            "Title",
            update_job_title,
          ),
          _dropDownMenu(
            "Job Size",
            "select",
            job_size,
            update_experience,
          ),
          Text(
            "Description",
            textAlign: TextAlign.left,
          ),
          SizedBox(
            height: 10,
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width,
            child: TextFormField(
              minLines: 4,
              maxLength: 150,
              validator: (String? value) {
                return value!.length < 100
                    ? 'Minimum character length is 100'
                    : null;
              },

              onChanged: (val) {
                update_description(val);
                _finish_stage(stage);
              },
              maxLines: null,
              // expands: true,
              decoration: InputDecoration(
                  isCollapsed: true,
                  hintText: "Description",
                  hintStyle: TextStyle(color: Colors.grey),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey)),
                  focusedBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Theme.of(context).primaryColor))),
            ),
          ),
          SizedBox(height: 16),
          _nextStep(context, _active),
        ],
      ),
    );
  }

  Widget _secondStage(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Column(children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              "Time",
              textAlign: TextAlign.left,
            ),
            SizedBox(
              height: 10,
            ),
            TextField(
              readOnly: true,
              onTap: () {
                showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(Duration(days: 5 * 365)))
                    .then((value) {
                  if (value != null) {
                    update_deadline(value.toIso8601String());
                    _finish_stage(stage);
                  }
                });
              },
              controller: _dateController,
              decoration: InputDecoration(
                  hintText: "Deadline",
                  hintStyle: TextStyle(color: Colors.grey),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                      borderRadius: BorderRadius.circular(10)),
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey))),
            ),
            SizedBox(
              height: 20,
            ),
          ],
        ),
        _dropDownMenu(
          "Experince Level",
          "select",
          ["Any one", "Normal", "Pro"],
          update_frequency,
        ),
        _nextStep(context, _active)
      ]),
    );
  }

  Widget _thirdStage(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Column(children: [
        _dropDownMenu(
          "Payment Structure *",
          "Structure",
          ["Hourly", "By project", "By milestone"],
          update_payment_structure,
        ),
        _textField("Rate *", "Rate", update_rate),
        _dropDownMenu("Payment Method *", "Method", ["CCP", "Debit card"],
            update_payment_method),
        _nextStep(context, _active)
      ]),
    );
  }

  Widget _fourthStage(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Files Uploaded",
              style: TextStyle(color: Colors.grey),
            ),
            Container(
              margin: EdgeInsets.fromLTRB(0, 10, 0, 20),
              alignment: Alignment.topLeft,
              padding: EdgeInsets.all(15),
              width: MediaQuery.of(context).size.width,
              height: 200,
              decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(10)),
              child: SingleChildScrollView(
                child: Wrap(
                  direction: Axis.horizontal,
                  crossAxisAlignment: WrapCrossAlignment.start,
                  alignment: WrapAlignment.start,
                  runSpacing: 10,
                  spacing: 5,
                  children: _uploadedFilesTypes.map(
                    (e) {
                      if (e == "word") {
                        return SvgPicture.asset(
                            "assets/icons/word-file-type.svg");
                      } else if (e == "pdf") {
                        return SvgPicture.asset(
                            "assets/icons/pdf-file-typ.svg");
                      } else {
                        return SvgPicture.asset(
                            "assets/icons/mc-file-image.svg");
                      }
                    },
                  ).toList(),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () async {
                    try {
                      FilePickerResult? result = await FilePicker.platform
                          .pickFiles(allowMultiple: true);
                      if (result != null) {
                        for (var file in result.files) {
                          String _addedType;
                          if (lookupMimeType(file.path!)!.contains("pdf")) {
                            _addedType = "pdf";
                          } else if (lookupMimeType(file.path!)!
                              .contains("word")) {
                            _addedType = "word";
                          } else {
                            _addedType = "image";
                          }
                          _files.add(File(file.path!));
                          setState(() {
                            _uploadedFilesTypes.add(_addedType);
                          });
                        }
                        update_files(_files);
                        Fluttertoast.showToast(
                            msg: "File Uploaded",
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.CENTER,
                            timeInSecForIosWeb: 1,
                            fontSize: 16.0);
                      }
                    } catch (e) {
                      Fluttertoast.showToast(
                          msg: "Error please try again",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.CENTER,
                          timeInSecForIosWeb: 1,
                          fontSize: 16.0);
                    }
                  },
                  child: DottedBorder(
                    dashPattern: [6, 6, 6, 6],
                    borderType: BorderType.RRect,
                    radius: Radius.circular(15),
                    color: Colors.grey,
                    child: Container(
                      width: 150,
                      height: 50,
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.file_download_outlined),
                            SizedBox(
                              width: 5,
                            ),
                            Text("Upload Files"),
                          ]),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    context.read<CreateJobBloc>().add(SetStage(stage + 1));
                    _nextStage();
                  },
                  child: Container(
                      width: 150,
                      height: 50,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(200)),
                          color: Color(0xFF7360DF)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Next Step",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                          Icon(
                            Icons.arrow_right_alt,
                            color: Colors.white,
                          )
                        ],
                      )),
                ),
              ],
            )
          ],),
    );
  }

  Widget _fifthStage(BuildContext context, CreateJobState state) {
    if (state is CreateJobLoading) {
      return Column(
        children: [
          SizedBox(
            height: 100,
          ),
          Container(
            height: 100,
            width: 100,
            child: CircularProgressIndicator(
              value: null,
            ),
          ),
        ],
      );
    } else if (state is CreateJobSuccess) {
      Fluttertoast.showToast(msg: "Job created Successfully");
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(
            context,
            context.read<AuthRepo>().user_model!.role == FREELACNER
                ? Routes.freelancer_main_page
                : Routes.client_main_page);
      });
      return Container();
    } else if (state is CreateJobError) {
      Fluttertoast.showToast(msg: "Error : Please try again");
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(
            context,
            context.read<AuthRepo>().user_model!.role == FREELACNER
                ? Routes.freelancer_main_page
                : Routes.client_main_page);
      });
      return Container();
    } else {
      return SingleChildScrollView(
        child: Column(children: [
          FeedJobCard(
            jobModel: _jobModel,
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                GestureDetector(
                  onTap: () {
                    context.read<CreateJobBloc>().add(CreateJob(_jobModel));
                  },
                  child: Container(
                      width: 150,
                      height: 50,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(200)),
                          color: Color(0xFF7360DF)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Post Now",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                          Icon(
                            Icons.arrow_right_alt,
                            color: Colors.white,
                          )
                        ],
                      )),
                ),
              ],
            ),
          ),
        ]),
      );
    }
  }

  Row _nextStep(BuildContext context, bool active) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        GestureDetector(
          onTap: () {
            if (active) {
              context.read<CreateJobBloc>().add(SetStage(stage + 1));
              _nextStage();
            } else {
              if (_jobModel.description.length < 100) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Description should be 100 or more chars"),
                  ),
                );
              }
            }
          },
          child: Container(
              width: 150,
              height: 50,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(200)),
                  color: active
                      ? Color(0xFF7360DF)
                      : Color.fromARGB(106, 115, 96, 223)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Next Step",
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  Icon(
                    Icons.arrow_right_alt,
                    color: Colors.white,
                  )
                ],
              )),
        ),
      ],
    );
  }

  Column _textField(
    String label,
    String hint,
    void Function(String) callback,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.black),
          textAlign: TextAlign.left,
        ),
        SizedBox(
          height: 10,
        ),
        TextField(
          keyboardType:
              label.contains("ate") ? TextInputType.number : TextInputType.text,
          onChanged: (val) {
            callback(val);
            _finish_stage(stage);
          },
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey),
            contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey),
              borderRadius: BorderRadius.circular(10),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: Theme.of(context).primaryColor,
              ),
            ),
            suffix: label.contains("ate") ? Text(" DA") : SizedBox(),
          ),
        ),
        SizedBox(
          height: 20,
        ),
      ],
    );
  }

  Column _dropDownMenu(String label, String hint, List<String> entries,
      void Function(String?) callback) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(
          label,
          textAlign: TextAlign.left,
          style: TextStyle(color: Colors.black),
        ),
        SizedBox(
          height: 10,
        ),
        DropdownMenu(
          trailingIcon: RotatedBox(
            child: Text(
              "<",
              style: TextStyle(fontSize: 20, color: Colors.grey),
            ),
            quarterTurns: 3,
          ),
          selectedTrailingIcon: RotatedBox(
            child: Text(
              "<",
              style: TextStyle(fontSize: 20, color: Colors.grey),
            ),
            quarterTurns: 1,
          ),
          onSelected: (val) {
            callback(val);
            _finish_stage(stage);
          },
          width: MediaQuery.of(context).size.width - 40,
          hintText: hint,
          inputDecorationTheme: InputDecorationTheme(
              border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                  borderRadius: BorderRadius.circular(10)),
              contentPadding:
                  EdgeInsets.symmetric(vertical: 15, horizontal: 10),
              hintStyle: TextStyle(color: Colors.grey)),
          dropdownMenuEntries: entries
              .map((e) => DropdownMenuEntry(label: e, value: e))
              .toList(),
        ),
        SizedBox(
          height: 20,
        ),
      ],
    );
  }
}

class ProgressSpecifier extends StatefulWidget {
  final int index;
  final String label;
  final bool active;
  const ProgressSpecifier(
      {super.key,
      required this.index,
      required this.label,
      required this.active});

  @override
  State<ProgressSpecifier> createState() => _ProgressSpecifierState();
}

class _ProgressSpecifierState extends State<ProgressSpecifier> {
  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: (MediaQuery.of(context).size.width - 65) / 2 +
          (widget.index - 1) * (MediaQuery.of(context).size.width - 65) * 0.45,
      child: Container(
        child: Column(
          children: [
            AnimatedContainer(
              width: 50,
              height: 50,
              duration: Duration(milliseconds: 500),
              curve: Curves.linear,
              decoration: BoxDecoration(
                color: widget.active ? Color(0xFF7360DF) : Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: widget.active ? Color(0xFF7360DF) : Colors.grey,
                  width: 2,
                ),
              ),
              child: Center(
                  child: TextButton(
                onPressed: () => (),
                child: Text(
                  widget.index.toString(),
                  style: TextStyle(
                      color: widget.active ? Colors.white : Colors.black,
                      fontWeight: FontWeight.bold),
                ),
              )),
            ),
            SizedBox(
              height: 5,
            ),
            Text(
              widget.label,
              style: TextStyle(
                  color: widget.active ? Color(0xFF7360DF) : Colors.grey,
                  fontWeight: FontWeight.bold,
                  fontSize: 9),
            )
          ],
        ),
      ),
    );
  }
}
