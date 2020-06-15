
import 'package:flutter/material.dart';
import 'package:music_player/tiles/drawer_tile.dart';

class DrawerHome extends StatelessWidget {
  final Color secondColorRed = Color(0xFFFF4444);

  @override
  Widget build(BuildContext context) {

    Widget _buildDrawerBack() => Container(
      decoration: BoxDecoration(
          gradient: LinearGradient(
              colors:
              [secondColorRed, Theme.of(context).primaryColor],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight
          )
      ),
    );

    return Drawer(
      child: Stack(
        children: <Widget>[
          _buildDrawerBack(),
          ListView(
            padding: EdgeInsets.only(left: 32, top: 16),
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(top: 10),
                padding: EdgeInsets.fromLTRB(0, 16, 16, 8),
                height: 120,
                child: Image.asset("assets/iconlogoprojota.png", fit: BoxFit.fitHeight, height: 70,),
              ),
              Divider(
                color: Color(0xFFe8e8e8),
              ),
              DrawerTile(Icons.playlist_play, 'Fila de reprodução'),
              DrawerTile(Icons.share, 'Compartilhar'),
              DrawerTile(Icons.star_border, 'Avaliar'),
              DrawerTile(Icons.playlist_add, 'Ajude-nós a melhorar'),
            ],
          )
        ],
      ),
    );
  }
}
