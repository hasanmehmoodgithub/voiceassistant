
import 'dart:convert';
import 'dart:developer';
import 'dart:ffi';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:lottie/lottie.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:voiceassistant/generated/assets.dart';
import 'package:voiceassistant/src/app_colors.dart';
import 'package:animate_do/animate_do.dart';


class VoiceAssistant extends StatefulWidget {
  const VoiceAssistant({super.key});

  @override
  VoiceAssistantState createState() => VoiceAssistantState();
}

class VoiceAssistantState extends State<VoiceAssistant> {
  final FlutterTts flutterTts = FlutterTts();
  final stt.SpeechToText speech = stt.SpeechToText();
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  DatabaseReference? _rackDataRef;

  @override
  void initState() {
    super.initState();
    _rackDataRef = _database.ref().child('rack_data');

    getByProductCode("43742-0064");
    initSpeechToText();
    initTextToSpeech();


  }

  Future<void> initTextToSpeech() async {
    await flutterTts.setSharedInstance(true);
    setState(() {});
  }

  Future<void> initSpeechToText() async {
    await speech.initialize();
    setState(() {});
  }
  void _queryData(String productCode) {

    _rackDataRef!
        .orderByChild('ProductCode')
        .equalTo(productCode)
        .once().then((value) {
      // if (value.snapshot.value != null) {
      //    Map<dynamic, dynamic> map = value.snapshot.value;
      //   // Since Realtime Database does not preserve the order of keys in maps,
      //   // we'll just grab the first entry in the map.
      //   final Map<String, dynamic> firstEntry = Map.from(map.values.first);
      //   return Warehouse.fromMap(firstEntry);
      // }

      if (value.snapshot.value != null) {
        try
        {
          Map<dynamic, dynamic> data = value.snapshot.value as Map;
          // WarehouseEntry warehouseEntry=WarehouseEntry.fromJson(data);
          print(data);
          generatedContent=data.toString();
          flutterTts.speak("record found");
          setState(() {

          });

        }
        catch(e)
      {
        generatedContent='something went wrong please try again';
        flutterTts.speak(generatedContent!);
        setState(() {

        });
      }

      } else {
        print('No data found for ProductCode: $productCode');
        generatedContent='No data found for ProductCode: $productCode';
        flutterTts.speak(generatedContent!);
        setState(() {

        });

      }
    });
  }
  String? generatedContent;
  void _speechRecognitionHandler() async {
    bool available = await speech.initialize();
    if (available) {
      log('available');
      speech.listen(
        onResult: (result) {
          setState(() {
          });
          String recognizedText = result.recognizedWords;
          if(speech.isNotListening)
          {
            _responseHandler(recognizedText);
          }

        },
      );
    }
    else{
      log('no available');
    }
  }
  void _responseHandler(String recognizedText) {
    if (recognizedText.contains('hi') ||
        recognizedText.contains('hello') ||
        recognizedText.contains('siri') ) {
      setState(() {
        generatedContent='Hi welcome, what I can do for you';
      });
      flutterTts.speak(generatedContent!);
    } else if (recognizedText.contains('find me a product')) {
      final RegExp regex = RegExp(r'[\w-]+');
      final Iterable<Match> matches = regex.allMatches(recognizedText);
      final String? productCode = matches.last.group(0);
      setState(() {
        generatedContent='Finding product $productCode, please wait.';
      });
      flutterTts.speak(generatedContent!);
      _queryData("43742-0064");
    } else {
      setState(() {
        generatedContent='Invalid command.please speak again';
      });
      flutterTts.speak(generatedContent!);
    }
    setState(() {
    });
  }


  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: BounceInDown(

            child: const Text('Siri',style: TextStyle(color: Colors.black),),
          ),
          centerTitle: true,

        ),
        body: SingleChildScrollView(
          child: Container(
            width: double.infinity,

            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Image.asset(Assets.imagesAppBanner,height: 120,width: 120,),  // Assuming you have a logo.png file in your assets folder
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  margin: const EdgeInsets.symmetric(horizontal: 40).copyWith(
                    top: 30,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: AppColor.borderColor,
                    ),
                    borderRadius: BorderRadius.circular(20).copyWith(
                      topLeft: Radius.zero,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: Text(
                      generatedContent == null
                          ? 'Welcome, what task can I do for you? Click below button to activate'
                          : generatedContent!,
                      style: TextStyle(
                        fontFamily: 'Cera Pro',
                        color: AppColor.mainFontColor,
                        fontSize: generatedContent == null ? 25 : 18,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                speech.isNotListening? InkWell(
                    onTap: (){
                      getByProductCode("43742-0064");
                      //_speechRecognitionHandler();
                    },
                    child: Lottie.asset(Assets.imagesStart,height:200,width: 200)):
                InkWell(
                    onTap: (){
                      speech.stop();
                    },
                    child: Lottie.asset(Assets.imagesLottie,height: 300,width: 300)),

              ],
            ),
          ),
        ),
      ),
    );
  }
 getByProductCode(String productCode) async {

    final DatabaseEvent snapshot = await _rackDataRef!
        .orderByChild('ProductCode')
        .equalTo(productCode)
        .once();
    var data=snapshot.snapshot.children;
  if(data.isEmpty)
    {

    }
  else{
    data.forEach((element) {

     // log(element.runtimeType.toString());
      var data = element.value;

      // If the data is a Map, you can cast it and access fields like this:
      if (data is Map<dynamic, dynamic>) {
        var someField = data['PalletSize'];
        log(someField,name: "inmap");


      }

      // If the data is a List, you can cast it and iterate through it like this:
      if (data is List<dynamic>) {
        for (var item in data) {
          log(item["PalletSize"],name: "inlist");
        }
      }

      // Or if the data is a single value, you can just use it directly:
      log(data.toString(),name: "el");
    });

        }


}}
class Warehouse {
  final String bay;
  final double boxSize;
  final String customer;
  final double freeSpacePercent;
  final String locationType;
  final double occupiedSpacePercent;
  final double palletSize;
  final int pallets;
  final String productCode;
  final int quantity;
  final String rack;
  final String section;
  final int totalBox;
  final int totalProduct;

  Warehouse({
    required this.bay,
    required this.boxSize,
    required this.customer,
    required this.freeSpacePercent,
    required this.locationType,
    required this.occupiedSpacePercent,
    required this.palletSize,
    required this.pallets,
    required this.productCode,
    required this.quantity,
    required this.rack,
    required this.section,
    required this.totalBox,
    required this.totalProduct,
  });

  factory Warehouse.fromMap(Map<String, dynamic> map) {
    return Warehouse(
      bay: map['Bay'],
      boxSize: map['BoxSize'].toDouble(),
      customer: map['Customer'],
      freeSpacePercent: map['FreeSpacePercent'].toDouble(),
      locationType: map['LocationType'],
      occupiedSpacePercent: map['OccupiedSpacePercent'].toDouble(),
      palletSize: map['PalletSize'].toDouble(),
      pallets: map['Pallets'],
      productCode: map['ProductCode'],
      quantity: map['Quantity'],
      rack: map['Rack'],
      section: map['Section'],
      totalBox: map['TotalBox'],
      totalProduct: map['TotalProduct'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'Bay': bay,
      'BoxSize': boxSize,
      'Customer': customer,
      'FreeSpacePercent': freeSpacePercent,
      'LocationType': locationType,
      'OccupiedSpacePercent': occupiedSpacePercent,
      'PalletSize': palletSize,
      'Pallets': pallets,
      'ProductCode': productCode,
      'Quantity': quantity,
      'Rack': rack,
      'Section': section,
      'TotalBox': totalBox,
      'TotalProduct': totalProduct,
    };
  }

}