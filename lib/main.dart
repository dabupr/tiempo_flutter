import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:tiempo/map.dart';
import 'package:weather/weather.dart';
import 'package:intl/intl.dart';
import 'package:weather_icons/weather_icons.dart';
import 'package:weather_animation/weather_animation.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather App',
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
  late Weather barcelonaInfo;
  late List<Weather> forecastData;
  bool loaded = false;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<bool> isGPSAllow() async {
    //bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        //SHOW ERROR SNAKCBAR GPS
        return false;
      }
    }
    return true;
  }

  void getWheater() {}

  void loadData() async {
    List<Weather> forecastDataAux;
    bool gpsON = await isGPSAllow();
    Position position = Position(
        longitude: 37.421998333333335,
        latitude: -122.084,
        timestamp: DateTime.now(),
        accuracy: -122.084,
        altitude: -122.084,
        heading: 37.42199833333333,
        speed: 1,
        speedAccuracy: 1);
    WeatherFactory wf = WeatherFactory("c2a16e82b452224ed739fc97129cc16c");

    if (gpsON) {
      position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.low);
      //print('Location find');
      forecastDataAux = await wf.fiveDayForecastByLocation(position.latitude, position.longitude);
      forecastData = await wf.fiveDayForecastByLocation(position.latitude, position.longitude);
    } else {
      forecastDataAux = await wf.fiveDayForecastByCityName("Barcelona");
      forecastData = await wf.fiveDayForecastByCityName("Barcelona");
    }

    //List<Weather> forecastDataAux = await wf.fiveDayForecastByLocation(position.latitude, position.longitude);
    //forecastData = await wf.fiveDayForecastByLocation(position.latitude, position.longitude);

    forecastData.clear();
    String name = "day";
    for (int x = 0; x < forecastDataAux.length; x++) {
      if ((DateFormat('EEEE').format(forecastDataAux[x].date!)) != name) {
        //Borrem els dies repes per que la api retorna per horas
        //print(name);
        forecastData.add(forecastDataAux[x]);
        name = DateFormat('EEEE').format(forecastDataAux[x].date!);
      } else {
        name = DateFormat('EEEE').format(forecastDataAux[x].date!);
      }
    }

    if (forecastData.length > 1) {
      // Borrem el dia eque esta repetit per que ja surt en gran...
      forecastData.removeAt(0);
    }
    if (gpsON) {
      position = position;
      barcelonaInfo = await wf.currentWeatherByLocation(position.latitude, position.longitude);
    } else {
      barcelonaInfo = await wf.currentWeatherByCityName("Barcelona");
    }

    setState(() {
      loaded = true;
    });
  }

  Widget getBody(BuildContext context) {
    return Stack(
      children: [
        getBackGraund(),
        Column(
          children: [
            const Spacer(),
            const Spacer(),
            loaded ? getPrincipal() : Container(),
            const Spacer(),
            const Spacer(),
            Center(
              child: Container(
                height: (MediaQuery.of(context).size.height / 2),
                width: MediaQuery.of(context).size.width - 48,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(
                    Radius.circular(20),
                  ),
                  color: Colors.black.withOpacity(0.4),
                ),
                child: loaded
                    ? forecast()
                    : const Center(
                        child: SizedBox(
                          height: 45,
                          width: 45,
                          child: CircularProgressIndicator(),
                        ),
                      ),
              ),
            ),
            const Spacer(),
          ],
        )
      ],
    );
  }

  Widget getPrincipal() {
    return Column(
      children: [
        Center(
          child: GestureDetector(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: [
                Flexible(
                  child: Text(
                    barcelonaInfo.areaName.toString(),
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 32,
                      color: Colors.white,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ),
                const Icon(
                  Icons.location_on,
                )
              ],
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LocationAppExample()),
              );
            },
          ),
        ),
        Center(
          child: Text(
            barcelonaInfo.temperature.toString().replaceAll(" Celsius", "º"),
            style: const TextStyle(fontSize: 90, color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                barcelonaInfo.weatherMain.toString(),
                style:
                    const TextStyle(fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold),
              ),
              BoxedIcon(getIcon(barcelonaInfo.weatherMain.toString()),
                  color: Colors.white, size: 32),
            ],
          ),
        ),
        Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "L:${barcelonaInfo.tempMin.toString().replaceAll(" Celsius", "º")}",
                style:
                    const TextStyle(fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold),
              ),
              Text(
                " H:${barcelonaInfo.tempMax.toString().replaceAll(" Celsius", "º")}",
                style:
                    const TextStyle(fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ],
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
                    "${forecastData[index].weatherDescription} ",
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                    ),
                  ),
                  BoxedIcon(getIcon(forecastData[index].weatherMain.toString()),
                      color: Colors.white),
                ],
              ),
            ),
          );
        });
  }

  IconData getIcon(String description) {
    switch (description) {
      case "Rain":
        return WeatherIcons.rain;
      case "Clouds":
        return WeatherIcons.cloud;
      case "Clear":
        return WeatherIcons.day_sunny;
      case "Thunderstorm":
        return WeatherIcons.thunderstorm;
      case "Drizzle":
        return WeatherIcons.raindrop;
      case "Snow":
        return WeatherIcons.snow;
      case "Fog":
        return WeatherIcons.fog;
      case "Tornado	":
        return WeatherIcons.tornado;
    }
    return WeatherIcons.day_sunny;
  }

  Widget getBackGraund() {
    return loaded
        ? SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: _getTypeOfBackgraund(),
          )
        : SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: WeatherScene.weatherEvery.getWeather(),
          );
  }

  Widget _getTypeOfBackgraund() {
    String description = barcelonaInfo.weatherMain.toString();
    switch (description) {
      case "Rain":
        return WeatherScene.rainyOvercast.getWeather();
      case "Clouds":
        return WeatherScene.sunset.getWeather();
      case "Clear":
        return WeatherScene.scorchingSun.getWeather();
      case "Thunderstorm":
        return WeatherScene.snowfall.getWeather();
      case "Snow":
        return WeatherScene.snowfall.getWeather();
    }
    return WeatherScene.weatherEvery.getWeather();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: getBody(context),
    );
  }
}
