import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}
class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  String _url = "https://owlbot.info/api/v4/dictionary/";
  String _token = "0ad42e4d496d072a6cde58612f0bd62397cbc7d0";

  TextEditingController _controller = TextEditingController();

  StreamController _streamController;
  Stream _stream;

  Timer _debounce;

  _search() async{
    if(_controller.text == null || _controller.text.length ==0){
      _streamController.add(null);
      return ;
    }
    _streamController.add("waiting");
    Response response = await get(_url + _controller.text.trim(), headers:{"Authorization": "Token " + _token});
    _streamController.add(json.decode(response.body));
  }

  @override
  void initState() {
    super.initState();
    _streamController = StreamController();
    _stream = _streamController.stream;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text('Flictionary',)),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(48.0),
          child: Row(children: [
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(left: 12.0, bottom: 8.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24.0),
                  color: Colors.white
                ),
                child: TextFormField(
                  onChanged: (String text){
                    if(_debounce ?.isActive ?? false) _debounce.cancel();
                    _debounce = Timer(const Duration (milliseconds: 1000),(){
                      _search();
                    });
                  },
                  controller: _controller,
                  decoration: InputDecoration(
                    hintText: "Search for a word",
                    contentPadding: const EdgeInsets.only(left: 24.0),
                    border: InputBorder.none,
                  )
                ),
              ),
            ),
            IconButton(
              icon: Icon(Icons.search,color: Colors.white,),
              onPressed: (){
                _search();
              },)
          ],),
          ),
      ),
      body: Container(
        margin: EdgeInsets.all(8.0),
        child: StreamBuilder(
          builder:(BuildContext context, AsyncSnapshot snapshot){
            if(snapshot.data == null){
              return Center(child: Text('Enter a search word'),);
            }

            if(snapshot.data == "waiting"){
              return Center(child: CircularProgressIndicator(),);
            }

            return ListView.builder(
              itemCount: snapshot.data["definitions"].length,
              itemBuilder: (BuildContext context, int index){
                return ListBody(
                  children: [
                    Container(
                      color: Colors.grey[300],
                      child: ListTile(
                        leading: snapshot.data["definitions"][index]["image_url"] == null ? null : CircleAvatar(
                          backgroundImage: NetworkImage(snapshot.data["definitions"][index]["image_url"]),
                        ),
                      title: Text(_controller.text.trim() + "(" + snapshot.data["definitions"][index]["type"] + ")"),
                        ),
                        ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(snapshot.data["definitions"][index]["definition"]),
                        )
                  ],
                );
              },
              
            );
          },
          stream: _stream,),
      ),
    );
  }
}
