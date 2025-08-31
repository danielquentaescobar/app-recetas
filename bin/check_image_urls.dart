import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../lib/firebase_options.dart';

/// Script simple para verificar URLs de imágenes en Firebase
void main() async {
  try {
    print('🔍 Verificando URLs de imágenes en Firebase...');
    
    // Inicializar Firebase para web (más simple)
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.web,
    );
    
    final firestore = FirebaseFirestore.instance;
    
    // Obtener todas las recetas
    final recipesSnapshot = await firestore.collection('recipes').get();
    
    print('📊 Encontradas ${recipesSnapshot.docs.length} recetas');
    print('');
    
    for (var doc in recipesSnapshot.docs) {
      final data = doc.data();
      final imageUrl = data['imageUrl'] as String?;
      final title = data['title'] as String? ?? 'Sin título';
      
      print('🍽️  $title (${doc.id})');
      
      if (imageUrl != null) {
        print('   📸 URL: $imageUrl');
        if (imageUrl.contains('localhost:6708')) {
          print('   ⚠️  NECESITA MIGRACIÓN (puerto 6708)');
        } else if (imageUrl.contains('localhost:8085')) {
          print('   ✅ URL CORRECTA (puerto 8085)');
        } else {
          print('   ❓ URL EXTERNA');
        }
      } else {
        print('   ❌ Sin imagen');
      }
      print('');
    }
    
    print('✅ Verificación completada');
    
  } catch (e) {
    print('❌ Error: $e');
    print('Stack trace: ${StackTrace.current}');
  }
  
  exit(0);
}
