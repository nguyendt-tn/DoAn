import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:launch_review/launch_review.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingPage extends StatefulWidget {
  @override
  _SettingPage createState() => _SettingPage();
}

class _SettingPage extends State<SettingPage> {
  void _launchURL(String _url) async => await canLaunch(_url)
      ? await launch(_url)
      : throw 'Could not launch $_url';
  String encodeQueryParameters(Map<String, String> params) {
    return params.entries
        .map((e) =>
            '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');
  }

  DateTime currentBackPressTime;
  Future<bool> onWillPop() {
    DateTime now = DateTime.now();
    if (currentBackPressTime == null ||
        now.difference(currentBackPressTime) > Duration(seconds: 2)) {
      currentBackPressTime = now;
      EasyLoading.showToast('Bấm lần nữa để thoát ứng dụng');
      return Future.value(false);
    }
    return Future.value(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backwardsCompatibility: false,
          title: Text("Cái đặt",
              style: GoogleFonts.laila(
                  fontWeight: FontWeight.w600,
                  fontSize: 28,
                  color: Colors.green)),
          elevation: 0,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              color: Colors.white,
            ),
          ),
        ),
        body: WillPopScope( 
          onWillPop: onWillPop,
          child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(10),
            child: Column(
              children: <Widget>[
                SizedBox(
                  height: 10,
                ),
                SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height * 0.17,
                    child: InkWell(
                      onTap: () {},
                      child: Container(
                        padding: EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Color(0xFF63F2D8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 1,
                              blurRadius: 1,
                              offset:
                                  Offset(0, 1), // changes position of shadow
                            ),
                          ],
                        ),
                        child: Column(
                          children: <Widget>[
                            SizedBox(
                              height: 10,
                            ),
                            SizedBox(
                                child: Align(
                              alignment: Alignment.center,
                              child: Text(
                                "Grammaker Pro",
                                style: GoogleFonts.laila(
                                    color: Colors.white,
                                    fontSize: 30,
                                    fontWeight: FontWeight.w700),
                              ),
                            )),
                            SizedBox(
                              height: 5,
                            ),
                            SizedBox(
                                child: Align(
                              alignment: Alignment.center,
                              child: Text(
                                "V1.0.0",
                                style: GoogleFonts.laila(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w500),
                              ),
                            )),
                            SizedBox(
                              height: 5,
                            ),
                            SizedBox(
                                child: Align(
                              alignment: Alignment.center,
                              child: Text(
                                "support@nguyendt.dev",
                                style: GoogleFonts.laila(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w500),
                              ),
                            )),
                          ],
                        ),
                      ),
                    )),
                SizedBox(
                  height: 30,
                ),
                SizedBox(
                  child: Container(
                    padding: EdgeInsets.only(
                        top: 30, bottom: 30, left: 10, right: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 1,
                          blurRadius: 1,
                          offset: Offset(0, 1), // changes position of shadow
                        ),
                      ],
                    ),
                    child: Column(
                      children: <Widget>[
                        InkWell(
                          onTap: () {
                            Uri emailLaunchUri = Uri(
                              scheme: 'mailto',
                              path: 'support@nguyendt.dev',
                              query: encodeQueryParameters(<String, String>{
                                'subject': 'Grammaker Pro Android - Feedback'
                              }),
                            );
                            _launchURL(emailLaunchUri.toString());
                          },
                          child: Row(
                            children: <Widget>[
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.15,
                                child: Icon(
                                  Icons.mail,
                                  size: 27,
                                  color: Color(0xFF1A3873),
                                ),
                              ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.01,
                              ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.6,
                                child: Text(
                                  "Để lại phản hồi",
                                  style: GoogleFonts.laila(
                                      color: Colors.grey[700],
                                      fontWeight: FontWeight.w500,
                                      fontSize: 23),
                                ),
                              ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.05,
                              ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.05,
                                child: Icon(
                                  Icons.chevron_right,
                                  size: 27,
                                  color: Colors.grey[800],
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 30,
                        ),
                        InkWell(
                          onTap: () {
                            LaunchReview.launch(
                                androidAppId: 'pro.tndev.grammar');
                          },
                          child: Row(
                            children: <Widget>[
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.15,
                                child: Icon(
                                  Icons.star,
                                  size: 27,
                                  color: Color(0xFF1A3873),
                                ),
                              ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.01,
                              ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.60,
                                child: Text(
                                  "Đành già 5 sao",
                                  style: GoogleFonts.laila(
                                      color: Colors.grey[700],
                                      fontWeight: FontWeight.w500,
                                      fontSize: 23),
                                ),
                              ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.05,
                              ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.05,
                                child: Icon(
                                  Icons.chevron_right,
                                  size: 27,
                                  color: Colors.grey[800],
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 30,
                        ),
                        InkWell(
                          onTap: () {
                            _launchURL(
                                'https://app.nguyendt.dev/ngrammar-pro/privacy/');
                          },
                          child: Row(
                            children: <Widget>[
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.15,
                                child: Icon(
                                  Icons.https,
                                  size: 27,
                                  color:Color(0xFF1A3873),
                                ),
                              ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.01,
                              ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.6,
                                child: Text(
                                  "Chình sàch bảo mật",
                                  style: GoogleFonts.laila(
                                      color: Colors.grey[700],
                                      fontWeight: FontWeight.w500,
                                      fontSize: 23),
                                ),
                              ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.05,
                              ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.05,
                                child: Icon(
                                  Icons.chevron_right,
                                  size: 27,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 30,
                        ),
                        InkWell(
                          onTap: () {
                            _launchURL(
                                'https://app.nguyendt.dev/ngrammar-pro/terms/');
                          },
                          child: Row(
                            children: <Widget>[
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.15,
                                child: Icon(
                                  Icons.verified_user,
                                  size: 27,
                                  color: Color(0xFF1A3873),
                                ),
                              ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.01,
                              ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.6,
                                child: Text(
                                  "Điều khoản sử dụng",
                                  style: GoogleFonts.laila(
                                      color: Colors.grey[700],
                                      fontWeight: FontWeight.w500,
                                      fontSize: 23),
                                ),
                              ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.05,
                              ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.05,
                                child: Icon(
                                  Icons.chevron_right,
                                  size: 27,
                                  color: Colors.grey[800],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        )));
  }
}
