import 'package:flutter/material.dart';
import 'package:music_player/controllers/music_controller.dart';
import 'package:provider/provider.dart';

class AppBarHome extends StatefulWidget with PreferredSizeWidget{
  @override
  _AppBarHomeState createState() => _AppBarHomeState();

  @override
  // TODO: implement preferredSize
  Size get preferredSize => Size.fromHeight(55);
}

class _AppBarHomeState extends State<AppBarHome> {

  final TextEditingController _filter = new TextEditingController();
  Icon _searchIcon = Icon(Icons.search);
  Widget _appBarTitle = Image.asset("assets/projotalogo.png", fit: BoxFit.fitHeight, height: 35,);

  @override
  Widget build(BuildContext context) {
    final musicController = Provider.of<MusicController>(context);

    return AppBar(
      title: _appBarTitle,
      elevation: 0,
      centerTitle: true,
      actions: <Widget>[
        IconButton(
            icon: _searchIcon,
            onPressed: (){
              setState(() {
                if (this._searchIcon.icon == Icons.search) {
                  this._searchIcon = new Icon(Icons.close);
                  this._appBarTitle = new TextField(
                    controller: _filter,
                    autofocus: true,
                    onChanged: (text){
                      musicController.changeSearch(text);
                    },
                    style: TextStyle(fontSize: 16.0, color: Colors.white),
                    decoration: new InputDecoration(
                        prefixIcon: new Icon(Icons.search, color: Colors.white,),
                        hintText: 'Nome da música ou artista',
                        hintStyle: TextStyle(fontSize: 16.0, color: Colors.white70),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                          //  when the TextFormField in unfocused
                        ) ,
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                          //  when the TextFormField in focused
                        )
                    ),
                    cursorColor: Colors.white,
                  );
                } else {
                  this._searchIcon = new Icon(Icons.search);
                  this._appBarTitle = Image.asset("assets/projotalogo.png", fit: BoxFit.fitHeight, height: 35,);
                  _filter.clear();
                  musicController.changeSearch('');
                }
              });
            })
      ],
    );
  }
}
