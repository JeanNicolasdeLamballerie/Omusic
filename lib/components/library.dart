import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:googleapis/drive/v3.dart' as ga;
import 'package:http/http.dart';
import 'package:omusic/components/drive_api.dart';
import 'package:omusic/components/card.dart';
//import 'package:loading_animations/loading_animations.dart';
// import 'package:_discoveryapis_commons/_discoveryapis_commons.dart' as commons;

import 'package:flutter_spinkit/flutter_spinkit.dart';
// import 'package:audio_service/audio_service.dart';
import 'package:omusic/components/player.dart';

class ListReader {
  final Uint8List byteList;
  int position = 0;
  int defaultLength = 1;
  ListReader(
      {required this.byteList, this.position = 0, this.defaultLength = 1});
  int advanceSingle() {
    position += 1;
    return byteList[position - 1];
  }

  Uint8List advanceTwice() {
    position += 2;
    return byteList.sublist(position - 2, position);
  }

  Uint8List advanceReaderList(int? range) {
    range ??= defaultLength;
    position += range;
    return byteList.sublist(position - range, position);
  }

  advanceReaderString(int? range) {
    return String.fromCharCodes(advanceReaderList(range));
  }
}

//& UTIL : Checks for audio compatibility & returns values from the file description
class Getter {
  final ga.File element;
  final List<String> extensions = <String>[
    ".MP3",
    ".WAV",
    ".AAC",
    ".WMA",
    ".AMR",
    ".OGG",
    ".MIDI"
  ];
  Getter(this.element);
  String getLink() {
    return element.webContentLink ?? '';
  }

  String getId() {
    return element.id ?? '';
  }

  String getName() {
    return element.name ?? '';
  }

  List<String> getParent() {
    return element.parents ?? [];
  }

  bool isAudio() {
    return extensions.any((extension) =>
        element.name!.toLowerCase().contains(extension.toLowerCase()));
  }

//& UTIL : splits List into a List<List>
  static List<List<Audio>> partition(List<Audio> arr, int size) {
    var len = arr.length;
    List<List<Audio>> chunks = [];

    for (var i = 0; i < len; i += size) {
      var end = (i + size < len) ? i + size : len;
      chunks.add(arr.sublist(i, end));
    }
    return chunks;
  }

//& UTIL : splits List<List> into a List<List<List>>
  static List<List<List<Audio>>> partitionToPage(
      List<List<Audio>> arr, int size) {
    var len = arr.length;
    List<List<List<Audio>>> chunks = [];

    for (var i = 0; i < len; i += size) {
      var end = (i + size < len) ? i + size : len;
      chunks.add(arr.sublist(i, end));
    }
    return chunks;
  }
}

//& Defines an audio item
class Audio {
  final String extension;
  final String name;
  final String id;
  final String link;
  final List<String> parents;
  Audio(this.name, this.id, this.link, this.parents, this.extension);
}

//! Defines a view for the Library

class LibraryView extends StatefulWidget {
  final DriveAPI api;
  final AudioPlayerHandler handler;
  const LibraryView({Key? key, required this.api, required this.handler})
      : super(key: key);
  @override
  createState() => LibraryState();
}

class LibraryState extends State<LibraryView> {
  bool loading = true;
  String txt = "test";
  late AudioPlayerHandler handler;
  int currentPage = 0;
  List<Audio> audioFilesNames = [];
  Map<String, String> finalMap = {};
//test
  void setTXT(t) {
    setState(() {
      txt = t;
    });
  }

  void setCurrentPage(int nb, int max) {
    if (currentPage + nb < 0 || currentPage + nb > max) {
      return;
    }
    setState(() {
      currentPage = currentPage + nb;
    });
  }

  void setLoading(bool? load) {
    setState(() {
      loading = load ?? !loading;
    });
  }

  @override
  initState() {
    super.initState();
    handler = widget.handler;
  }

  @override
  Widget build(context) {
    checkFiles() async {
      var api = widget.api.getAPI();
      // try {

      // } catch (err) {
      //   print('Error occured : ');
      //   print(err);
      //   return;
      // }
      ;
      var files = await api.files.list($fields: '*');
      files.files?.forEach((element) async {
        Getter fetchedFile = Getter(element);
        if (element.name!.contains("TEST")) {
          print(element.name);
        }
        if (fetchedFile.isAudio() && element.name == "TESTFILE.wav") {
          print("ID : ");
          // print(element.mimeType);
          print(element.id!);
          print(element.name!);

          //Todo BUG REPORT : Doesn't seem to be able to request the last byte
          var l = int.parse(element.size ?? "-1");
          if (l != -1) {
            l = l - 1;
          }
          ga.Media partiallyDownloadedFile = await api.files.get(
                  // "1mhBkXgwZj7sle-h2YQulDPa0HPClXeYz",
                  element.id!,
                  // downloadOptions: const ga.DownloadOptions()
                  downloadOptions:
                      ga.PartialDownloadOptions(ga.ByteRange(42305206, l)))
              //!ga.PartialDownloadOptions(ga.ByteRange(0, 60000)))
              //!as ga.Media;
              as ga.Media;
          print("partial download");
          // print(partiallyDownloadedFile.length);
          //! print(partiallyDownloadedFile.contentType);
          //!ByteStream str = partiallyDownloadedFile.stream as ByteStream;
          ByteStream str = partiallyDownloadedFile.stream as ByteStream;

          var riff = await str.toBytes();
          print(riff.length);
          print("length"); // 44 038 726 // 42 305 206
          ListReader reader = ListReader(byteList: riff, position: 12);
          var b = riff.sublist(0, 4);
          var c = riff.sublist(4, 8);
          var d = riff.sublist(8, 12);
          int getInt32Reader() => reader
              .advanceReaderList(4)
              .buffer
              .asByteData()
              .getInt32(0, Endian.little);
          print(c.buffer.asByteData().getInt32(0, Endian.little)); //filesize
          print(String.fromCharCodes(b));
          print("8-12${String.fromCharCodes(d)}");
          print(reader.position);
          print(reader.advanceReaderString(4));
          print(reader.position);
          print(getInt32Reader());
          print(reader.position);
          print(reader.advanceTwice());
          print(reader.position);
          print(reader.advanceTwice());
          print(reader.position);
          print(getInt32Reader());
          print(reader.position);
          print(getInt32Reader());
          print(reader.position);
          print(reader.advanceTwice());
          print(reader.position);
          print(reader.advanceTwice());
          print(reader.position);
          print(reader.advanceReaderString(4));
          print("here");

          print(reader.position);
          print(getInt32Reader());
          print(reader.position);
          try {
            var edf = utf8.decode(riff, allowMalformed: true);
            print("yo");
            print(edf.contains("info"));
            print(edf.contains("this is the artist !"));
            if (txt == "test") {
              var ai = (edf.indexOf("ID3") - 1500);

              setTXT("START ($ai ) ---- ${edf.substring(ai)}----- END");
            }
            print(edf.length);
          } catch (err) {
            print("err !");
            print(err);
          }
          print(reader.advanceReaderList(4));
          print(reader.advanceReaderList(4));
          print(reader.advanceReaderList(4));
          print(reader.advanceReaderList(4));
          print(reader.advanceReaderList(4));
          int i = 0;
          bool found = false;
          int firstIndex = -1;
          while (i < 300000) {
            i++;
            var r = reader.advanceReaderList(4);

            if (r.toString() != [0, 0, 0, 0].toString()) {
              if (!found) {
                firstIndex = reader.position;
                print("different !");
                print(r);
                print(i);
                print(firstIndex);
              }
              found = true;
              if (found && i > firstIndex + 15) {
                break;
              }
            }
            if (found && i > firstIndex + 15) {
              break;
            }
          }
          print(firstIndex);
          print(reader.byteList.sublist(firstIndex, firstIndex + 4));
          print(String.fromCharCodes(
              reader.byteList.sublist(firstIndex, firstIndex + 4)));
          print(i);
          print("done");

          // str.join("");
          // print(await str.join(','));
          try {
            //var vl = await str.bytesToString();
            //   print(vl);
          } catch (err) {
            // print(err);
          }
          return;

          // Future.value(a).then((e) {
          //   print("Partial dl");
          //   print(e);
          // });

          // var f =
          //     await api.files.get(fetchedFile.element.id!, $fields: 'Range:10');
          // print(f);
          String name = fetchedFile.getName();
          String id = fetchedFile.getId();
          String link = fetchedFile.getLink();
          List<String> parents = fetchedFile.getParent();
          String extension = name.split('.').last;
          name = name.replaceAll(".$extension", '');
          audioFilesNames.add(Audio(name, id, link, parents, extension));
          if (element.parents != null) {
            //todo check for values ? => Set directories
          }

          return;
        }
      });
      return;
      Map<String, Future> parentsFiles = {};
      audioFilesNames.sort((a, b) {
        return a.name.toLowerCase().compareTo(b.name.toLowerCase());
      });
      for (var audio in audioFilesNames) {
        {
          if (parentsFiles[audio.parents[0]] == null) {
            parentsFiles[audio.parents[0]] =
                api.files.get(audio.parents[0], $fields: '*');
          }
        }
      }
      print("error?");
      List<dynamic> values = await Future.wait(parentsFiles.values);
      print(" no error?");
      for (int i = 0; i < values.length; i++) {
        finalMap[parentsFiles.keys.elementAt(i)] = values[i].name;
      }
      setLoading(false);
      print('Loading finished');
    }

    //~ Start the fetching of the audio files descriptions
    if (loading) {
      try {
        checkFiles();
      } catch (err) {
        print(err);
        print("edf");
      }
    }

    return LayoutBuilder(builder: (context, constraints) {
      //~ Get the constraints & layout of the current screen
      var parentHeight = constraints.maxHeight;
      var parentWidth = constraints.maxWidth;

      if (loading) {
        //! Visual values if loader is apparent
        const padding = 40.0;
        const totalPadding = padding * 2;
        const size = 50;
        const totalSize = size + totalPadding;
        //! Loader element
        var square = const Padding(
          padding: EdgeInsets.all(padding),
          child: SpinKitFoldingCube(
            color: Colors.blue,
            size: 50.0,
          ),
        );

        //! Determining the amount of loaders to display
        var numberInRow = ((parentWidth / 1.5) / (totalSize)).floor();
        var numberOfRows = ((parentHeight / 1.5) / (totalSize)).floor();
        debugPrint(
            'Max height: $parentHeight, max width: $parentWidth, max number :  $numberInRow, max rows : $numberOfRows');
        //! Finally, create array of widgets
        var widgets = List.filled(
            numberOfRows,
            Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.filled(numberInRow, square)));
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            //! Iterate over the previously created widgets and display them
            children: [
              Container(child: SingleChildScrollView(child: Text(txt)))
            ],
            //& children: widgets.map((row) {
            //   return Container(child: row);
            // }).toList(),
          ),
        );
      }

      //? ----------------------------------------------------------------------------------------------
      else // Display the library because the loading is finished.                                //? --
      //? ----------------------------------------------------------------------------------------------

      {
        //! Visual values if library cards are apparent

        const padding = 40.0;
        const totalPadding = padding * 2;
        const sizeHorizontal = 150.0;
        const sizeVertical = 50;

        const totalSizeHorizontal = sizeHorizontal + totalPadding;
        const totalSizeVertical = sizeVertical + totalPadding;

        //! Determining the amount of cards to display

        var numberInRow = ((parentWidth / 1.5) / (totalSizeHorizontal)).floor();
        var numberOfRows = ((parentHeight / 1.2) / (totalSizeVertical)).floor();

        //! Making sure our build still display at least one row & element to avoid errors

        if (numberOfRows < 1) {
          numberOfRows = 1;
        }
        if (numberInRow < 1) {
          numberInRow = 1;
        }

        //! Partitioning the audio files into lists corresponding to rows

        var lists = Getter.partition(audioFilesNames, numberInRow);

        //! Partitioning the list of rows into lists corresponding to pages

        List<List<List<Audio>>> allLists =
            Getter.partitionToPage(lists, numberOfRows);

        //! Making sure that changing the screen size dynamically doesn't send us to a non-existent index
        var maxIndex = allLists.length - 1;
        if (currentPage > maxIndex) {
          setCurrentPage(maxIndex, maxIndex);
        }
        //! Booleans used to determine if the buttons should be greyed out
        bool isFirstPage = currentPage == 0;
        bool isLastPage = currentPage == maxIndex;

        //! Previous & next page
        goNext() {
          setCurrentPage(1, maxIndex);
        }

        goPrevious() {
          setCurrentPage(-1, maxIndex);
        }

        //? Start rendering
        return Center(
            child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  disabledColor: Colors.grey,
                  splashRadius: 25,
                  onPressed: isFirstPage ? null : () => goPrevious(),
                  icon: Icon(Icons.keyboard_arrow_left_sharp,
                      color: isFirstPage
                          ? Colors.grey
                          : Theme.of(context).primaryColor),
                ),
                Text("Current page : ${currentPage + 1}/${allLists.length}"),
                IconButton(
                  disabledColor: Colors.grey,
                  splashRadius: 25,
                  onPressed: isLastPage ? null : () => goNext(),
                  icon: Icon(Icons.keyboard_arrow_right_sharp,
                      color: isLastPage
                          ? Colors.grey
                          : Theme.of(context).primaryColor),
                ),
              ],
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: allLists[currentPage].map((row) {
                MainAxisAlignment alignment = MainAxisAlignment.center;
                if (isLastPage) {
                  //& check if we are in the last row
                  List<Audio> lastRow = allLists[currentPage]
                      .elementAt(allLists[currentPage].length - 1);
                  if (row == lastRow) {
                    alignment = MainAxisAlignment.start;
                  }
                }
                return Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: alignment,
                    children: row
                        .map((Audio audio) => Expanded(
                            child: CardView(
                                extension: audio.extension,
                                parents: audio.parents,
                                parentsMap: finalMap,
                                handler: handler,
                                name: audio.name,
                                id: audio.id,
                                link: audio.link)))
                        .toList());
              }).toList(),
            )
          ],
        ));
      }
    });
  }
}
