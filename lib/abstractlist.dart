import 'package:flutter/material.dart';
import 'package:proj2/pract1.dart';
void main() {
  runApp(
    /*pract1(),*/
    MyApp(
      items: List<ListItem>.generate(
        10,
            (i) {
          if (i % 6 == 0) {
            return HeadingItem('Heading $i');
          } else {
            return MessageItem('Sender $i', 'Message body $i');
          }
        },
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  final List<ListItem> items;

  const MyApp({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    const title = 'Mixed List';

    return MaterialApp(
      title: title,
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.amber,
          title: const Text(title,style: TextStyle(color: Colors.red),),
        ),
        body: ListView.builder(
          // Let the ListView know how many items it needs to build.
          itemCount: items.length,
          // Provide a builder function. This is where the magic happens.
          // Convert each item into a widget based on the type of item it is.
          itemBuilder: (context, index) {
            final item = items[index];

            return ListTile(
              title: item.buildTitle(context),
              subtitle: item.buildSubtitle(context),
            );
          },
        ),
      ),
    );
  }
}

/// The base class for the different types of items the list can contain.
abstract class ListItem {
  /// The title line to show in a list item.
  Widget buildTitle(BuildContext context);

  /// The subtitle line, if any, to show in a list item.
  Widget buildSubtitle(BuildContext context);
}
/// A ListItem that contains data to display a heading.
class HeadingItem implements ListItem {
  final String heading;
  HeadingItem(this.heading);
  @override
  Widget buildTitle(BuildContext context) {
    return Text(
      heading,
      style: TextStyle(color: Colors.amber,fontSize: 43),
    );
  }
  @override
  Widget buildSubtitle(BuildContext context) => const SizedBox.shrink();
}
/// A ListItem that contains data to display a message.
class MessageItem implements ListItem {
  final String sender;
  final String body;
  MessageItem(this.sender, this.body);
  @override
  Widget buildTitle(BuildContext context) => Text(sender,style: TextStyle(color: Colors.redAccent),);
  @override
  Widget buildSubtitle(BuildContext context) => Text(body);
}