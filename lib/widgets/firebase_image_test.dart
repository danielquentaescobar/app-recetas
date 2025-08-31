import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// Widget simple para probar imágenes de Firebase Storage directamente
class FirebaseImageTest extends StatelessWidget {
  final String firebaseUrl;
  final double? width;
  final double? height;

  const FirebaseImageTest({
    Key? key,
    required this.firebaseUrl,
    this.width,
    this.height,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print('🧪 Probando imagen Firebase directamente: $firebaseUrl');
    
    return Column(
      children: [
        Text('URL: $firebaseUrl', style: TextStyle(fontSize: 10)),
        SizedBox(height: 8),
        Container(
          width: width ?? 200,
          height: height ?? 200,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.red, width: 2),
          ),
          child: CachedNetworkImage(
            imageUrl: firebaseUrl,
            width: width,
            height: height,
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(
              color: Colors.blue[100],
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 8),
                  Text('Cargando...', style: TextStyle(fontSize: 12)),
                ],
              ),
            ),
            errorWidget: (context, url, error) {
              print('❌ Error al cargar imagen Firebase: $error');
              return Container(
                color: Colors.red[100],
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error, color: Colors.red),
                    SizedBox(height: 8),
                    Text('Error: ${error.toString()}', 
                         style: TextStyle(fontSize: 10, color: Colors.red)),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
