import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grammar_app/screens/check.dart';
import 'package:grammar_app/screens/translate.dart';
import 'package:grammar_app/screens/dictionary/index.dart';
import 'package:grammar_app/screens/setting.dart';
import 'package:grammar_app/screens/pracetice/index.dart';
import 'package:bottom_navy_bar/bottom_navy_bar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_archive/flutter_archive.dart';
import 'package:path/path.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class Nav extends StatefulWidget {
  @override
  _NavState createState() => _NavState();
}

class _NavState extends State<Nav> {
  _setup() async {
    Directory directory = await getExternalStorageDirectory();
    var filePath = join(directory.path, "omo_v1");
    if (File(filePath).existsSync()) {
      return;
    } else {
      // EasyLoading.show(status: "Đang giải nén dữ liệu, vui lòng chờ");
      EasyLoading.show(status: "Đang giải nén dữ liệu, vui lòng chờ");
      ByteData data = await rootBundle.load('assets/database/omo_v1');
      List<int> bytes =
          data.buffer.asInt8List(data.offsetInBytes, data.lengthInBytes);
      await File(filePath).writeAsBytes(bytes);

      final zipFile = File(filePath);
      final destinationDir = Directory(directory.path);
      try {
        await ZipFile.extractToDirectory(
            zipFile: zipFile,
            destinationDir: destinationDir,
            onExtracting: (zipEntry, progress) {
              print('progress: ${progress.toStringAsFixed(1)}%');
              print('name: ${zipEntry.name}');
              print('isDirectory: ${zipEntry.isDirectory}');
              print(
                  'modificationDate: ${zipEntry.modificationDate.toLocal().toIso8601String()}');
              print('uncompressedSize: ${zipEntry.uncompressedSize}');
              print('compressedSize: ${zipEntry.compressedSize}');
              print('compressionMethod: ${zipEntry.compressionMethod}');
              print('crc: ${zipEntry.crc}');
              EasyLoading.dismiss();
              return ZipFileOperation.includeItem;
            });
      } catch (e) {
        print(e);
      }
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _setup();
  }

  int _selectIndex = 0;
  List<Widget> _widgetOptions = <Widget>[
    CheckPage(),
    TranslatePage(),
    DictionaryPage(),
    PraceticePage(),
    SettingPage()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _widgetOptions.elementAt(_selectIndex),
      ),
      bottomNavigationBar: BottomNavyBar(
        containerHeight: 70,
        items: <BottomNavyBarItem>[
          BottomNavyBarItem(
            icon: Icon(
              Icons.spellcheck,
              size: 32,
            ),
            title: Text("Grammar", style: GoogleFonts.laila()),
            activeColor: Colors.blue,
          ),
          BottomNavyBarItem(
              icon: Icon(
                Icons.g_translate,
                size: 32,
              ),
              title: Text("Tranlsate", style: GoogleFonts.laila()),
              activeColor: Colors.blue),
          BottomNavyBarItem(
              icon: Icon(
                Icons.import_contacts,
                size: 32,
              ),
              title: Text("Dictionary", style: GoogleFonts.laila()),
              activeColor: Colors.blue),
          BottomNavyBarItem(
              icon: Icon(
                Icons.assignment_turned_in,
                size: 32,
              ),
              title: Text("Practice", style: GoogleFonts.laila()),
              activeColor: Colors.blue),
          BottomNavyBarItem(
              icon: Icon(
                Icons.settings,
                size: 32,
              ),
              title: Text(
                "Setting",
                style: GoogleFonts.laila(),
              ),
              activeColor: Colors.blue)
        ],
        selectedIndex: _selectIndex,
        showElevation: true,
        onItemSelected: (index) => setState(() {
          _selectIndex = index;
        }),
      ),
    );
  }
}
