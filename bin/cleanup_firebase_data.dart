import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../lib/firebase_options.dart';

/// Script para limpiar recetas con timestamps nulos
void main() async {
  try {
    print('🔧 Iniciando limpieza de datos problemáticos...');
    
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.web,
    );
    
    final firestore = FirebaseFirestore.instance;
    
    // Obtener todas las recetas
    final recipesSnapshot = await firestore.collection('recipes').get();
    
    print('📊 Encontradas ${recipesSnapshot.docs.length} recetas para revisar');
    
    int fixedCount = 0;
    final batch = firestore.batch();
    
    for (var doc in recipesSnapshot.docs) {
      try {
        final data = doc.data();
        bool needsUpdate = false;
        Map<String, dynamic> updates = {};
        
        // Verificar y corregir campos de timestamp
        if (data['createdAt'] == null) {
          updates['createdAt'] = FieldValue.serverTimestamp();
          needsUpdate = true;
          print('⚠️ Corrigiendo createdAt para ${doc.id}');
        }
        
        if (data['updatedAt'] == null) {
          updates['updatedAt'] = FieldValue.serverTimestamp();
          needsUpdate = true;
          print('⚠️ Corrigiendo updatedAt para ${doc.id}');
        }
        
        // Verificar y corregir campos que pueden estar null
        if (data['rating'] == null) {
          updates['rating'] = 0.0;
          needsUpdate = true;
        }
        
        if (data['reviewsCount'] == null) {
          updates['reviewsCount'] = 0;
          needsUpdate = true;
        }
        
        if (data['likedBy'] == null) {
          updates['likedBy'] = [];
          needsUpdate = true;
        }
        
        if (data['isPublic'] == null) {
          updates['isPublic'] = true;
          needsUpdate = true;
        }
        
        if (data['tags'] == null) {
          updates['tags'] = [];
          needsUpdate = true;
        }
        
        if (data['categories'] == null) {
          updates['categories'] = [];
          needsUpdate = true;
        }
        
        if (needsUpdate) {
          batch.update(doc.reference, updates);
          fixedCount++;
        }
        
      } catch (e) {
        print('❌ Error procesando ${doc.id}: $e');
      }
    }
    
    if (fixedCount > 0) {
      await batch.commit();
      print('✅ Se corrigieron $fixedCount recetas');
    } else {
      print('✅ No se encontraron recetas que necesiten corrección');
    }
    
    print('🎉 Limpieza completada!');
    
  } catch (e) {
    print('❌ Error durante la limpieza: $e');
  }
  
  exit(0);
}
