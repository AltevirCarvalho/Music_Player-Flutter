import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:music_player/controllers/music_controller.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'music_tile.dart';

class DrawerTile extends StatelessWidget {

  final IconData icon;
  final String text;
  final Color customGrey = Color(0xFFe8e8e8);
  final Color secondColorRed = Color(0xFFFF4444);

  DrawerTile(this.icon, this.text);

  @override
  Widget build(BuildContext context) {
    final musicController = Provider.of<MusicController>(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () async {
          Navigator.of(context).pop();
          switch(text){
            case 'Fila de reprodução':
                showModalBottomSheet(
                    context: context,
                    builder: (BuildContext context) {
                      return Container(
                        color: Theme.of(context).primaryColor,
                        child: Column(
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Container(
                                  margin: EdgeInsets.only(top: 8),
                                  child: IconButton(
                                      icon: Icon(Icons.close, size: 28, color: Colors.white,),
                                      onPressed: (){
                                        Navigator.pop(context);
                                      }),
                                ),
                                Container(
                                  margin: EdgeInsets.only(bottom: 10, top: 18),
                                  alignment: Alignment.center,
                                  child: Text('Fila de reprodução', style: TextStyle(fontSize: 20, color: Colors.white)),
                                ),
                                IconButton(
                                    icon: Icon(Icons.close, size: 28, color: Colors.transparent,),
                                ),
                              ],
                            ),
                            Divider(
                              color: secondColorRed,
                            ),
                            Expanded(child: Observer(
                                builder: (_){
                                  if(musicController.listaReproducao==null){
                                    return Container(
                                      alignment: Alignment.center,
                                      child: Text('Nenhuma música tocando.', style: TextStyle(color: Colors.white, fontSize: 20),),
                                    );
                                  }else {
                                    return ListView.builder(
                                      padding: EdgeInsets.all(4),
                                      itemCount: musicController.listaReproducao
                                          .length,
                                      itemBuilder: (context, index) {
                                        return MusicTile(musicController
                                            .listaReproducao[index], true);
                                      },
                                    );
                                  }
                                }
                            ))
                          ],
                        ),
                      );
                    },
                );
              break;
            case 'Compartilhar':
              var whatsappUrl ="https://wa.me/5521965403233?text=Olha%20esse%20novo%20App%20de%20m%C3%BAsicas%20do%20Projota!";
              await canLaunch(whatsappUrl)? launch(whatsappUrl):print("Você não possui o Whatsapp instalado. Entre em contato pelo Whatsapp neste número 55 (21) 965403233.");
              break;
            case 'Avaliar':
              break;
            case 'Ajude-nós a melhorar':
              var whatsappUrl ="https://api.whatsapp.com/send?phone=5521965403233&text=Tenho%20uma%20sugest%C3%A3o!";
              await canLaunch(whatsappUrl)? launch(whatsappUrl):print("Você não possui o Whatsapp instalado. Entre em contato pelo Whatsapp neste número 55 (21) 965403233.");
              break;
          }
        },
        child: Container(
          height: 60,
          child: Row(
            children: <Widget>[
              Icon(icon, size: 28, color: customGrey),
              SizedBox(width: 28,),
              Text(text,
                style: TextStyle(color: customGrey, fontSize: 16),
              )
            ],
          ),
        ),
      ),
    );
  }
}