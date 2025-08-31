import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../lib/firebase_options.dart';

/// Script para migrar URLs de imágenes de puerto 6708 a 8085
void main() async {
  try {
    // Inicializar Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    
    print('🔄 Iniciando migración de URLs de imágenes...');
    
    final firestore = FirebaseFirestore.instance;
    
    // Obtener todas las recetas
    final recipesSnapshot = await firestore.collection('recipes').get();
    
    int updatedCount = 0;
    int totalCount = recipesSnapshot.docs.length;
    
    print('📊 Encontradas $totalCount recetas para revisar');
    
    for (var doc in recipesSnapshot.docs) {
      try {
        final data = doc.data();
        final imageUrl = data['imageUrl'] as String?;
        
        if (imageUrl != null && imageUrl.contains('localhost:6708/uploads/')) {
          // Necesita migración
          final newImageUrl = imageUrl.replaceAll(
            'localhost:6708/uploads/', 
            'localhost:8085/uploads/'
          );
          
          await doc.reference.update({'imageUrl': newImageUrl});
          
          print('✅ Migrada: ${doc.id}');
          print('   Antes: $imageUrl');
          print('   Después: $newImageUrl');
          print('');
          
          updatedCount++;
        }
      } catch (e) {
        print('❌ Error procesando receta ${doc.id}: $e');
      }
    }
    
    print('🎉 Migración completada!');
    print('📊 Total revisadas: $totalCount');
    print('🔄 Actualizadas: $updatedCount');
    
  } catch (e) {
    print('❌ Error en migración: $e');
  }
  
  // Terminar proceso
  exit(0);
}
