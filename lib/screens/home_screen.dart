import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:xml2json/xml2json.dart';

import '../utilities/utilities.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var dio = Dio();

  String please = 'Please wait';
  String latLong = 'Please wait while fetching latLong';
  String location = 'Please wait while fetching Location';
  String countryDetails = 'Please wait while fetching Country details';
  Map<String, dynamic> country = {};

  String currencyRate = 'Please wait while fetching Currency Rate';

  @override
  void initState() {
    super.initState();
    appFlow();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("MedCollApp"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Text(
                    latLong,
                    style: TextStyle(
                        color: latLong.startsWith(please)
                            ? Colors.black
                            : Colors.blue),
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  SizedBox(
                    height: 20,
                    width: 20,
                    child: latLong.startsWith(please)
                        ? const CircularProgressIndicator.adaptive()
                        : const Icon(
                            Icons.check,
                            color: Colors.blue,
                          ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    location,
                    style: TextStyle(
                        color: latLong.startsWith(please)
                            ? Colors.grey
                            : (location.startsWith(please)
                                ? Colors.black
                                : Colors.blue)),
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  SizedBox(
                    height: 20,
                    width: 20,
                    child: latLong.startsWith(please)
                        ? const SizedBox()
                        : (location.startsWith(please)
                            ? const CircularProgressIndicator.adaptive()
                            : const Icon(
                                Icons.check,
                                color: Colors.blue,
                              )),
                  ),
                ],
              ),
            ),
            Visibility(
              visible: country.isEmpty,
              replacement: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text("countryCode = ${country["countryCode"]}\n"
                    "countryName = ${country["countryName"]}\n"
                    "isoNumeric = ${country["isoNumeric"]}\n"
                    "isoAlpha3 = ${country["isoAlpha3"]}\n"
                    "fipsCode = ${country["fipsCode"]}\n"
                    "continent = ${country["continent"]}\n"
                    "continentName = ${country["continentName"]}\n"
                    "capital = ${country["capital"]}\n"
                    "areaInSqKm = ${country["areaInSqKm"]}\n"
                    "population = ${country["population"]}\n"
                    "currencyCode = ${country["currencyCode"]}\n"
                    "languages = ${country["languages"]}\n"
                    "geonameId = ${country["geonameId"]}\n"
                    "west = ${country["west"]}\n"
                    "north = ${country["north"]}\n"
                    "east = ${country["east"]}\n"
                    "south = ${country["south"]}\n"
                    "postalCodeFormat = ${country["postalCodeFormat"]}\n"),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      countryDetails,
                      style: TextStyle(
                          color: location.startsWith(please)
                              ? Colors.grey
                              : (countryDetails.startsWith(please)
                                  ? Colors.black
                                  : Colors.blue)),
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                    SizedBox(
                      height: 20,
                      width: 20,
                      child: location.startsWith(please)
                          ? const SizedBox()
                          : (countryDetails.startsWith(please)
                              ? const CircularProgressIndicator.adaptive()
                              : const Icon(
                                  Icons.check,
                                  color: Colors.blue,
                                )),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    currencyRate,
                    style: TextStyle(
                        color: country.isEmpty
                            ? Colors.grey
                            : (currencyRate.startsWith(please)
                                ? Colors.black
                                : Colors.blue)),
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  SizedBox(
                    height: 20,
                    width: 20,
                    child: country.isEmpty
                        ? const SizedBox()
                        : (currencyRate.startsWith(please)
                            ? const CircularProgressIndicator.adaptive()
                            : const Icon(
                                Icons.check,
                                color: Colors.blue,
                              )),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  latLong = 'Please wait, fetching latLong';
                  location = 'Please wait, fetching Location';
                  countryDetails = 'Please wait while fetching Country details';
                  country = {};

                  currencyRate = 'Please wait while fetching Currency Rate';
                });

                appFlow();
              },
              child: const Text('Reset'),
            )
          ],
        ),
      ),
    );
  }

  void appFlow() async {
    Position? position = await getCurrentPosition();
    if (position == null) {
      return;
    }
    bool isInternetConnected = await checkNetworkConnectivity();
    if (isInternetConnected) {
      await getCurrentLocation(position);
      if (location.startsWith(please)) {
        return;
      }
      await getCountryDetails();
      if (country.isEmpty) {
        return;
      }
      await getCurrencyRate();
    }
  }

  getCurrentPosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!mounted) return;
    if (!serviceEnabled) {
      await showMessageDialog(context, 'Please Enable Location Service');
      Geolocator.openLocationSettings();
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (!mounted) return;
        await showMessageDialog(context, 'Location Permission are denied');
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (!mounted) return;
      await showMessageDialog(context,
          'Location permissions are permanently denied, we cannot request permissions.');
      return;
    }

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    latLong = "LatLong: ${position.latitude},${position.longitude}";
    setState(() {
      latLong = "LatLong: ${position.latitude},${position.longitude}";
    });

    return position;
  }

  getCurrentLocation(Position position) async {
    var response;
    try {
      response = await dio.get(
        'http://api.geonames.org/countryCode',
        queryParameters: {
          'lat': position.latitude,
          'lng': position.longitude,
          'username': 'medcollapp',
        },
      );
    } catch (e) {
      print(e);
      showMessageDialog(context, 'Could not get location');
    }
    if (response.statusCode == 200) {
      setState(() {
        location = "Location: " + response.data.trim();
      });
    }
  }

  getCountryDetails() async {
    var response;
    try {
      response = await dio.get(
        'http://api.geonames.org/countryInfo',
        queryParameters: {
          'country': location.substring(10),
          'username': 'medcollapp',
        },
      );
    } catch (e) {
      print(e);
      showMessageDialog(context, 'Could not get Country Details');
      return;
    }
    if (response.statusCode == 200) {
      final myTransformer = Xml2Json();

      myTransformer.parse(response.data);
      var json = myTransformer.toParker();
      country = jsonDecode(json)["geonames"]["country"];
    }
    setState(() {});
  }

  getCurrencyRate() async {
    var response;
    try {
      response = await dio.get(
        'https://api.exchangerate.host/latest',
        queryParameters: {
          'base': 'USD',
          'symbols': country['currencyCode'],
          'amount': 1,
          'places': 2,
        },
      );
    } catch (e) {
      print(e);
      showMessageDialog(context, 'Could not get Exchange rate');
      return;
    }
    if (response.statusCode == 200) {
      setState(() {
        currencyRate =
            "1 USD = ${response.data['rates'][country['currencyCode']]} ${country['currencyCode']}";
      });
    }
  }
}
