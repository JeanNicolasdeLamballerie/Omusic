import 'package:flutter/material.dart';
import 'package:googleapis/drive/v3.dart' as ga;
import 'package:omusic/components/drive_api.dart';
import 'package:omusic/components/card.dart';
//import 'package:loading_animations/loading_animations.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:audio_service/audio_service.dart';
import 'package:omusic/components/player.dart';

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

  static List<List<Audio>> partition(List<Audio> arr, int size) {
    var len = arr.length;
    List<List<Audio>> chunks = [];

    for (var i = 0; i < len; i += size) {
      var end = (i + size < len) ? i + size : len;
      chunks.add(arr.sublist(i, end));
    }
    return chunks;
  }

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

class Audio {
  final String extension;
  final String name;
  final String id;
  final String link;
  final List<String> parents;
  Audio(this.name, this.id, this.link, this.parents, this.extension);
}

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
      var files = await api.files.list($fields: '*');
      files.files?.forEach((element) {
        Getter fetchedFile = Getter(element);
        if (fetchedFile.isAudio()) {
          String name = fetchedFile.getName();
          String id = fetchedFile.getId();
          String link = fetchedFile.getLink();
          List<String> parents = fetchedFile.getParent();
          String extension = name.split('.').last;
          name.replaceAll(extension, '');
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
      print(parentsFiles);
      print("Hello world!");
      var values = await Future.wait(parentsFiles.values);
      print(values.toString());

      print("VALUES");
      for (int i = 0; i < values.length; i++) {
        print(values[i].name);
        print(parentsFiles.keys.elementAt(i));
        finalMap[parentsFiles.keys.elementAt(i)] = values[i].name ?? "";
      }
      setLoading(false);
      print(finalMap.toString());
      print('Loading finished');
    }

    if (loading) {
      try {
        checkFiles();
      } catch (err) {
        print(err);
      }
    }

    return LayoutBuilder(builder: (context, constraints) {
      var parentHeight = constraints.maxHeight;
      var parentWidth = constraints.maxWidth;

      if (loading) {
        const padding = 40.0;
        const totalPadding = padding * 2;
        const size = 50;
        const totalSize = size + totalPadding;
        var square = const Padding(
          padding: EdgeInsets.all(padding),
          child: SpinKitFoldingCube(
            color: Colors.blue,
            size: 50.0,
          ),
        );
        var numberInRow = ((parentWidth / 1.5) / (totalSize)).floor();
        var numberOfRows = ((parentHeight / 1.5) / (totalSize)).floor();
        debugPrint(
            'Max height: $parentHeight, max width: $parentWidth, max number :  $numberInRow, max rows : $numberOfRows');
        var widgets = List.filled(
            numberOfRows,
            Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.filled(numberInRow, square)));
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: widgets.map((row) {
              return Container(child: row);
            }).toList(),
          ),
        );
      } else {
        const padding = 40.0;
        const totalPadding = padding * 2;
        const sizeHorizontal = 150.0;
        const sizeVertical = 50;

        const totalSizeHorizontal = sizeHorizontal + totalPadding;
        const totalSizeVertical = sizeVertical + totalPadding;

        var numberInRow = ((parentWidth / 1.5) / (totalSizeHorizontal)).floor();

        var numberOfRows = ((parentHeight / 1.2) / (totalSizeVertical)).floor();
        if (numberOfRows < 1) {
          numberOfRows = 1;
        }
        if (numberInRow < 1) {
          numberInRow = 1;
        }
        var lists = Getter.partition(audioFilesNames, numberInRow);

        List<List<List<Audio>>> allLists =
            Getter.partitionToPage(lists, numberOfRows);
        // Row(
        //     mainAxisAlignment: MainAxisAlignment.center,
        //     children: audioFilesNames
        //         .map((audioFile) => Text(audioFile.name))
        //         .toList());
        if (currentPage > allLists.length - 1) {
          setCurrentPage(allLists.length - 1, allLists.length - 1);
        }

        bool isFirstPage = currentPage == 0;
        bool isLastPage = currentPage == allLists.length - 1;
        goNext() {
          setCurrentPage(1, allLists.length - 1);
        }

        goPrevious() {
          setCurrentPage(-1, allLists.length - 1);
        }

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
                return Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
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
