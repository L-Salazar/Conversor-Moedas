import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:async';

const request = 'https://api.hgbrasil.com/finance?format=json&key=6cc4b056';

void main() {
  runApp(MaterialApp(
    home: Home(),
    theme: ThemeData(primaryColor: Colors.amber, hintColor: Colors.amber),
  ));
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

Future<Map> getData() async {
  http.Response response = await http.get(request);
  return json.decode(response.body);
}

final realController = TextEditingController();
final euroController = TextEditingController();
final dolarController = TextEditingController();

 void realChange(String text) {
    double real = double.parse(text);
    dolarController.text = (real / dolar).toStringAsFixed(2);
    euroController.text = (real / euro).toStringAsFixed(2);
  }

  void dolarChange(String text) {
    double dolar = double.parse(text);
    realController.text = (dolar * dolar).toStringAsFixed(2);
    euroController.text = (dolar * dolar / euro).toStringAsFixed(2);
  }

  void euroChange(String text) {
    double euro = double.parse(text);
    realController.text = (euro * euro).toStringAsFixed(2);
    dolarController.text = (euro * euro / dolar).toStringAsFixed(2);
  }

double dolar;
double euro;

void refresh() {
  realController.text = '';
  dolarController.text = '';
  euroController.text = '';
  _toast();
}

void _toast() {
  Fluttertoast.showToast(
      msg: 'Campos resetados com sucesso, insira um novo valor',
      toastLength: Toast.LENGTH_LONG);
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('\$Convertor\$'),
        centerTitle: true,
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            color: Colors.amber,
            onPressed: refresh,
          ),
        ],
      ),
      body: FutureBuilder<Map>(
        future: getData(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
            case ConnectionState.none:
              return SpinKitWave(
                color: Colors.amber,
                size: 50.0,
              );
            default:
              if(snapshot.hasError) {
                return Text('Erro ao carregar dados');
              }
              else {
                dolar = snapshot.data['results']['currencies']['USD']['buy'];
                euro = snapshot.data['results']['currencies']['EUR']['buy'];

                return SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.all(10.0),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.monetization_on,
                              size: 150.0,
                              color: Colors.amber,
                            ),

                            criarCampo(realController, 'Real', 'R\$', realChange),
                            Divider(),
                            criarCampo(dolarController, 'Dólar', 'US\$', dolarChange),
                            Divider(),
                            criarCampo(euroController, 'Euro', '€', euroChange),

                          ],
                        ),
                      ),
                  ),
                );
              }  
          }
        },
      ),
    );
  }
}


Widget criarCampo (TextEditingController c,String text,String prefix,Function f) {
  return TextFormField(
    controller: c ,
    decoration: InputDecoration(
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.amber,width: 3.0)
      ),
      border: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.amber,width: 3.0)
      ),
      labelText: text,
      prefixText: prefix,
    ),
    onChanged: f,
    style: TextStyle(color: Colors.amber),
  );
}