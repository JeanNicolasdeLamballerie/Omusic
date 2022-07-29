import 'package:flutter/material.dart';
import 'package:googleapis/drive/v3.dart' as ga;
import 'package:omusic/components/drive_api.dart';
import 'package:omusic/components/card.dart';
//import 'package:loading_animations/loading_animations.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:audio_service/audio_service.dart';
import 'package:omusic/components/player.dart';

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
  late AudioPlayerHandler handler;
  int currentPage = 0;
  List<Audio> audioFilesNames = [];
  Map<String, String> finalMap = {};

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
      try {
        var partiallyDownloadedFile = await api.files.get(
            "1mhBkXgwZj7sle-h2YQulDPa0HPClXeYz",
            // element.id!,
            // downloadOptions: const ga.DownloadOptions()
            downloadOptions: ga.PartialDownloadOptions(ga.ByteRange(0, 10)));
        print("partial download");
        print(partiallyDownloadedFile);
        return;
      } catch (err) {
        print('Error occured : ');
        print(err);
        return;
      }
      ;
      var files = await api.files.list($fields: '*');
      files.files?.forEach((element) {
        if (element.mimeType!.contains('video')) {
          print("IDDDDD");
          print(element.id);
        }
        Getter fetchedFile = Getter(element);
        if (fetchedFile.isAudio()) {
          print("ID : ");
          print(element.mimeType);
          print(element.id!);

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
            children: widgets.map((row) {
              return Container(child: row);
            }).toList(),
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
                Text("Current page : " +
                    (currentPage + 1).toString() +
                    "/" +
                    allLists.length.toString()),
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
