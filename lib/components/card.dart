import 'package:flutter/material.dart';
import 'package:omusic/frog.dart';
import 'package:omusic/components/player.dart';

class CardView extends StatefulWidget {
  final String name;
  final String id;
  final String link;
  final String extension;

  final List<String> parents;
  final Map<String, String> parentsMap;
  late AudioPlayerHandler handler;

  CardView(
      {Key? key,
      required this.name,
      required this.id,
      required this.link,
      required this.extension,
      required this.handler,
      required this.parentsMap,
      required this.parents})
      : super(key: key);
  @override
  createState() => CardState();
}

class CardState extends State<CardView> {
  bool isSelected = false;
  void setSelected(bool? load) {
    setState(() {
      isSelected = !isSelected;
    });
  }

  @override
  Widget build(context) {
    String parentName = widget.parentsMap[widget.parents[0]] ?? "";
    return Card(
      margin: const EdgeInsets.all(3),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ListTile(
            leading: const Icon(Icons.album),
            title: Text(widget.name),
            subtitle: Text(parentName),
          ),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(widget.extension),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                TextButton(
                  child: const Text('BUY TICKETS'),
                  onPressed: () {/* ... */},
                ),
                const SizedBox(width: 8),
                TextButton(
                  child: const Text('LISTEN'),
                  onPressed: () {
                    InheritedSongWrapperState wrapper =
                        InheritedSongWrapper.of(context);
                    widget.handler.setLink(widget.link);
                    wrapper.changeParentName(parentName);
                    wrapper.changeSongName(widget.name);
                    wrapper.changeSongId(widget.id);
                    wrapper.changeSongLink(widget.link);
                    print(wrapper.mediaLink);
                    widget.handler.play();
                  },
                ),
                const SizedBox(width: 8),
              ],
            )
          ]),
        ],
      ),
    );
  }
}
