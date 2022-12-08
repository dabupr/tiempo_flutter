import 'package:flutter/material.dart';
import 'package:weather/weather.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool loaded = false;
  late Weather barcelonaInfo;
  late List<Weather> forecastData;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  void loadData() async {
    WeatherFactory wf = WeatherFactory("c2a16e82b452224ed739fc97129cc16c");

    List<Weather> forecastDataAux = await wf.fiveDayForecastByCityName("Barcelona");
    forecastData = await wf.fiveDayForecastByCityName("Barcelona");
    forecastData.clear();
    String name = "day";
    for (int x = 0; x < forecastDataAux.length; x++) {
      if ((DateFormat('EEEE').format(forecastDataAux[x].date!)) != name) {
        print(name);
        forecastData.add(forecastDataAux[x]);
        name = DateFormat('EEEE').format(forecastDataAux[x].date!);
      } else {
        name = DateFormat('EEEE').format(forecastDataAux[x].date!);
      }
    }

    barcelonaInfo = await wf.currentWeatherByCityName("Barcelona");

    setState(() {
      loaded = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: getBody(context),
    );
  }

  Widget getBody(BuildContext context) {
    return Stack(
      children: [
        Container(
            decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/back3.jpg"),
            fit: BoxFit.cover,
          ),
        )),
        Column(
          children: [
            const Spacer(),
            loaded ? getPrincipal() : const CircularProgressIndicator(),
            const Spacer(),
            const Spacer(),
            Container(
              height: (MediaQuery.of(context).size.height / 2),
              width: MediaQuery.of(context).size.width - 48,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(
                  Radius.circular(20),
                ),
                color: Colors.black.withOpacity(0.3),
              ),
              child: loaded ? forecast() : Container(),
            ),
            const Spacer(),
          ],
        )
      ],
    );
  }

  Widget getPrincipal() {
    return Container(
      child: Column(
        children: [
          const Center(
            child: Text(
              "Barcelona",
              style: TextStyle(fontSize: 28, color: Colors.white, fontWeight: FontWeight.normal),
            ),
          ),
          Center(
            child: Text(
              barcelonaInfo.temperature.toString().replaceAll(" Celsius", "º"),
              style:
                  const TextStyle(fontSize: 90, color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          Center(
            child: Text(
              barcelonaInfo.weatherMain.toString(),
              style:
                  const TextStyle(fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              //crossAxisAlignment: CrossAxisAlignment.,
              children: [
                Text(
                  "L:${barcelonaInfo.tempMin.toString().replaceAll(" Celsius", "º")}",
                  style: const TextStyle(
                      fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold),
                ),
                Text(
                  "H:${barcelonaInfo.tempMax.toString().replaceAll(" Celsius", "º")}",
                  style: const TextStyle(
                      fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget forecast() {
    return ListView.builder(
        itemCount: forecastData.length,
        itemBuilder: (BuildContext ctxt, index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "${DateFormat('EEEE').format(forecastData[index].date!)} ",
                    style: const TextStyle(fontSize: 18, color: Colors.white),
                  ),
                  Text(
                    forecastData[index].temperature.toString().replaceAll(" Celsius", "º "),
                    style: const TextStyle(fontSize: 32, color: Colors.white),
                  ),
                  Text(
                    forecastData[index].weatherDescription.toString(),
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }
}
