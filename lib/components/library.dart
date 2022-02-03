import 'package:flutter/material.dart';
import 'package:omusic/models/library.dart';
import 'package:omusic/login.dart';
import 'package:googleapis/drive/v3.dart';
import 'package:omusic/components/drive_api.dart';
import 'package:loading_animations/loading_animations.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class LibraryView extends StatefulWidget {
  final DriveAPI api;
  const LibraryView({Key? key, required this.api}) : super(key: key);
  @override
  createState() => LibraryState();
}

class LibraryState extends State<LibraryView> {
  bool loading = true;
  @override
  Widget build(context) {
    print(widget.api);
    print("DATA : ");
    print(widget.api.getData());
    checkFiles() async {
      var files = await widget.api.getAPI().files.list($fields: '*');
      files.files?.forEach((element) {
        print(element.id);
        print('------------------------------------------------');
        if (element.parents != null) {
          if (element.parents!.isNotEmpty) {
            print(element.name!);
            print(element.parents);
            print('has parents ! ');
          }
        }

        // // print(' => description : ');
        // // print(element.description);
        // print(' ==> Kind :  ');
        // print(element.kind);
        // print(' ==> parents :  ');
        // element.parents?.forEach((element) {
        //   print('parents : ' + element);
        // });
        // print(' ====> AppProp : ');
        // print(element.appProperties.toString());
      });
    }

    checkFiles();

    if (loading) {
      return LayoutBuilder(builder: (context, constraints) {
        var parentHeight = constraints.maxHeight;
        var parentWidth = constraints.maxWidth;

        const padding = 40.0;
        const totalPadding = padding * 2;
        const size = 40;
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
      });
    } else {
      return Text('Loaded');
    }
  }
}
