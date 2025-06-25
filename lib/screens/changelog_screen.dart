import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';

class ChangelogScreen extends StatelessWidget {
  const ChangelogScreen({super.key});

  @override
  Widget build(BuildContext context) {

    rootBundle.loadString('changelog.md');
    return Scaffold(
      appBar: AppBar(
        title: Text('Changelog'),
      ),
      body: FutureBuilder(
        future: rootBundle.loadString('changelog.md'),
        builder: (context, snapshot) {
          if(!snapshot.hasData){
            return CircularProgressIndicator();
          }
          
          return Markdown(data: snapshot.data!);
        }
      ),
    );
  }
}
