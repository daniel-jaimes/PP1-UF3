import 'package:flutter/material.dart';
import 'package:pp1/model/Pokemon.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _controller = TextEditingController();
  var _isLoading = false;
  Pokemon? _pokemon;
  void _resetPokemonInfo() {
    setState(() {
      _pokemon = null;
    });
  }

  Future<void> _searchPokemon(String value) async {
    setState(() {
      _isLoading = true;
    });
    final url = Uri.parse('https://pokeapi.co/api/v2/pokemon/$value');
    try {
      final response = await http.get(url);
      setState(() {
        _isLoading = false;
      });
      var result = json.decode(response.body);
      List<String> abilities = [];
      result["abilities"].forEach((value) {
        abilities.add(value["ability"]["name"]);
      });
      Pokemon pokemon = Pokemon(
        name: result["name"],
        height: result["height"],
        weight: result["weight"],
        abilities: abilities,
      );
      setState(() {
        _pokemon = pokemon;
      });
    } catch (error) {
      Fluttertoast.showToast(
        msg: "Ha ocurrido un problema al intentar conectar a la API" +
            error.toString(),
        toastLength: Toast.LENGTH_SHORT,
      );
      setState(() {
        _isLoading = false;
      });
    }

    @override
    void dispose() {
      _controller.dispose();
      super.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 200,
                child: TextField(
                  controller: _controller,
                  decoration: const InputDecoration(
                    hintText: "Escribe el id o el nombre del pokemon",
                  ),
                ),
              ),
              const SizedBox(
                width: 20,
              ),
              ElevatedButton(
                onPressed: () {
                  _controller.value.text.isNotEmpty
                      ? _searchPokemon(_controller.value.text)
                      : _resetPokemonInfo();
                },
                child: const Icon(Icons.search),
              )
            ],
          ),
          const SizedBox(
            height: 50,
          ),
          _isLoading
              ? CircularProgressIndicator()
              : Container(
                  child: Column(
                    children: [
                      Text("Resultado:"),
                      _pokemon == null
                          ? Text("")
                          : Column(
                              children: [
                                Text("Nombre: " + _pokemon!.name),
                                Text("Altura: " + _pokemon!.height.toString()),
                                Text("Peso: " + _pokemon!.weight.toString()),
                                Text("\nAbilidades:"),
                                Column(
                                  children: _pokemon!.abilities.map((ability) {
                                    return Text(ability);
                                  }).toList(),
                                ),
                              ],
                            ),
                    ],
                  ),
                ),
        ],
      ),
    );
  }
}
