import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

/// Script para agregar reseñas de ejemplo a Firebase
/// 
/// Ejecutar con: dart run scripts/add_sample_reviews.dart
void main() async {
  await Firebase.initializeApp();
  
  final firestore = FirebaseFirestore.instance;
  
  print('🌟 Agregando reseñas de ejemplo...');
  
  // Obtener algunas recetas existentes
  final recipesSnapshot = await firestore.collection('recipes').limit(3).get();
  
  if (recipesSnapshot.docs.isEmpty) {
    print('❌ No hay recetas en la base de datos. Ejecuta primero el script de población de recetas.');
    return;
  }
  
  // Reseñas de ejemplo
  final sampleReviews = [
    {
      'userName': 'María González',
      'userPhotoUrl': 'https://images.unsplash.com/photo-1494790108755-2616b612b5bc?w=150&h=150&fit=crop&crop=face',
      'rating': 5.0,
      'comment': '¡Increíble receta! La hice para mi familia y todos quedaron encantados. Los sabores son auténticos y las instrucciones muy claras.',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'isVisible': true,
    },
    {
      'userName': 'Carlos Rodríguez',
      'userPhotoUrl': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150&h=150&fit=crop&crop=face',
      'rating': 4.0,
      'comment': 'Muy buena receta, aunque le agregué un poco más de sal al gusto. El resultado final fue excelente.',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'isVisible': true,
    },
    {
      'userName': 'Ana Martínez',
      'userPhotoUrl': 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=150&h=150&fit=crop&crop=face',
      'rating': 5.0,
      'comment': 'Perfecta para el almuerzo familiar. Los ingredientes son fáciles de conseguir y el sabor es espectacular.',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'isVisible': true,
    },
    {
      'userName': 'Diego Silva',
      'userPhotoUrl': 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150&h=150&fit=crop&crop=face',
      'rating': 4.5,
      'comment': 'Receta tradicional muy bien explicada. Me recordó a la comida de mi abuela.',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'isVisible': true,
    },
    {
      'userName': 'Isabella Torres',
      'userPhotoUrl': 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=150&h=150&fit=crop&crop=face',
      'rating': 3.5,
      'comment': 'Buena receta, aunque me tomó un poco más de tiempo del esperado. El resultado vale la pena.',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'isVisible': true,
    },
    {
      'userName': 'Roberto Mendoza',
      'userPhotoUrl': 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150&h=150&fit=crop&crop=face',
      'rating': 5.0,
      'comment': '¡Excelente! Lo preparé para una cena especial y fue todo un éxito. Definitivamente lo volvería a hacer.',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'isVisible': true,
    },
  ];
  
  // Usuarios de ejemplo (simulados)
  final sampleUserIds = [
    'user_maria_example',
    'user_carlos_example', 
    'user_ana_example',
    'user_diego_example',
    'user_isabella_example',
    'user_roberto_example',
  ];
  
  int reviewCount = 0;
  
  // Agregar múltiples reseñas a cada receta
  for (final recipeDoc in recipesSnapshot.docs) {
    final recipeId = recipeDoc.id;
    final recipeName = recipeDoc.data()['title'] ?? 'Receta sin nombre';
    
    print('📝 Agregando reseñas para: $recipeName');
    
    // Agregar 2-4 reseñas por receta
    final numReviewsForRecipe = 2 + (reviewCount % 3); // 2, 3 o 4 reseñas
    
    for (int i = 0; i < numReviewsForRecipe && reviewCount < sampleReviews.length; i++) {
      final review = Map<String, dynamic>.from(sampleReviews[reviewCount]);
      review['recipeId'] = recipeId;
      review['userId'] = sampleUserIds[reviewCount % sampleUserIds.length];
      
      await firestore.collection('reviews').add(review);
      print('  ⭐ Reseña ${review['rating']} estrellas por ${review['userName']}');
      
      reviewCount++;
    }
    
    // Pequeña pausa entre recetas
    await Future.delayed(const Duration(milliseconds: 100));
  }
  
  print('✅ Agregadas $reviewCount reseñas de ejemplo');
  print('🔄 Los ratings promedio se actualizarán automáticamente');
  print('');
  print('📱 Ahora puedes:');
  print('  • Ver las reseñas en los detalles de las recetas');
  print('  • Agregar tus propias reseñas');
  print('  • Usar el sistema de favoritos');
  print('');
  print('🎉 ¡Sistema de reseñas listo para usar!');
}
