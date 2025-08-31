import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../lib/firebase_options.dart';

// Script para poblar Firebase con recetas de ejemplo
void main() async {
  // Inicializar Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final firestore = FirebaseFirestore.instance;
  
  print('🚀 Iniciando poblado de Firebase con recetas...');
  
  // Crear recetas de ejemplo
  final recetas = [
    {
      'title': 'Ceviche Peruano Tradicional',
      'description': 'Ceviche tradicional peruano con pescado fresco, limón y ají',
      'imageUrl': 'https://images.unsplash.com/photo-1624300629298-e9de39c13be5?w=500',
      'authorId': 'chef-peru',
      'authorName': 'Chef María Lima',
      'ingredients': [
        'Pescado blanco fresco - 500g',
        'Limones peruanos - 10 unidades',
        'Cebolla morada - 1 unidad',
        'Ají limo - 2 unidades',
        'Cilantro fresco - 1 manojo',
        'Camote - 2 unidades',
        'Choclo - 1 mazorca',
        'Sal marina al gusto'
      ],
      'instructions': [
        'Cortar el pescado en cubos de 2cm aproximadamente',
        'Exprimir los limones y colar el jugo para quitar semillas',
        'Cortar la cebolla morada en juliana muy fina',
        'Picar finamente el ají limo (sin semillas si no quieres picante)',
        'En un bowl, mezclar el pescado con sal marina',
        'Agregar el jugo de limón hasta cubrir el pescado',
        'Dejar marinar entre 10-15 minutos hasta que el pescado esté "cocido"',
        'Añadir la cebolla, ají y cilantro picado',
        'Servir inmediatamente con camote hervido y choclo'
      ],
      'preparationTime': 20,
      'cookingTime': 0,
      'servings': 4,
      'difficulty': 'Fácil',
      'region': 'Perú',
      'tags': ['Peruano', 'Ceviche', 'Marino', 'Fresco', 'Sin cocción'],
      'categories': ['Entrada', 'Plato Principal'],
      'isPublic': true,
      'rating': 4.8,
      'reviewsCount': 25,
      'likedBy': [],
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    },
    {
      'title': 'Empanadas Argentinas de Carne',
      'description': 'Empanadas criollas argentinas con un jugoso relleno de carne',
      'imageUrl': 'https://images.unsplash.com/photo-1601312540537-3f9765b2e0a2?w=500',
      'authorId': 'chef-argentina',
      'authorName': 'Chef Carlos Buenos Aires',
      'ingredients': [
        'Masa para empanadas - 12 tapas',
        'Carne picada especial - 500g',
        'Cebolla grande - 2 unidades',
        'Morrón rojo - 1 unidad',
        'Huevos duros - 2 unidades',
        'Aceitunas verdes - 100g',
        'Comino molido - 1 cucharadita',
        'Pimentón dulce - 1 cucharada',
        'Aceite de girasol - 3 cucharadas',
        'Sal y pimienta negra al gusto'
      ],
      'instructions': [
        'Picar finamente la cebolla y el morrón',
        'En una sartén grande, calentar el aceite y sofreír la cebolla',
        'Agregar el morrón y cocinar hasta que esté tierno',
        'Incorporar la carne picada y cocinar removiendo',
        'Condimentar con comino, pimentón, sal y pimienta',
        'Cocinar hasta que la carne esté bien dorada',
        'Dejar enfriar completamente el relleno',
        'Agregar huevo duro picado y aceitunas',
        'Rellenar las tapas con una cucharada del relleno',
        'Cerrar con el tradicional repulgue argentino',
        'Hornear a 200°C durante 18-20 minutos hasta dorar'
      ],
      'preparationTime': 45,
      'cookingTime': 20,
      'servings': 6,
      'difficulty': 'Intermedio',
      'region': 'Argentina',
      'tags': ['Argentino', 'Empanadas', 'Horno', 'Tradicional', 'Carne'],
      'categories': ['Entrada', 'Snack'],
      'isPublic': true,
      'rating': 4.7,
      'reviewsCount': 32,
      'likedBy': [],
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    },
    {
      'title': 'Arepa Venezolana Rellena',
      'description': 'Arepa tradicional venezolana con múltiples opciones de relleno',
      'imageUrl': 'https://images.unsplash.com/photo-1626200419199-391ae4be7a41?w=500',
      'authorId': 'chef-venezuela',
      'authorName': 'Chef Ana Caracas',
      'ingredients': [
        'Harina de maíz precocida - 2 tazas',
        'Agua tibia - 2.5 tazas',
        'Sal fina - 1 cucharadita',
        'Queso blanco rallado - 200g',
        'Pollo desmechado - 200g',
        'Aguacate maduro - 1 unidad',
        'Frijoles negros - 1 taza cocidos',
        'Mantequilla - 2 cucharadas'
      ],
      'instructions': [
        'En un bowl grande, mezclar la harina de maíz con sal',
        'Agregar el agua tibia gradualmente mientras mezclas',
        'Amasar con las manos hasta obtener una masa suave y sin grumos',
        'Dejar reposar la masa por 2-3 minutos',
        'Formar bolitas del tamaño de una pelota de tenis',
        'Aplastar las bolitas formando discos de 1cm de grosor',
        'Cocinar en un budare o sartén antiadherente sin aceite',
        'Cocinar 5-7 minutos por cada lado hasta que suenen huecas',
        'Hacer un corte lateral sin atravesar completamente',
        'Rellenar con los ingredientes de tu preferencia',
        'Servir inmediatamente mientras están calientes'
      ],
      'preparationTime': 15,
      'cookingTime': 20,
      'servings': 4,
      'difficulty': 'Fácil',
      'region': 'Venezuela',
      'tags': ['Venezolano', 'Arepa', 'Maíz', 'Versátil', 'Sin gluten'],
      'categories': ['Desayuno', 'Almuerzo', 'Cena'],
      'isPublic': true,
      'rating': 4.6,
      'reviewsCount': 18,
      'likedBy': [],
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    },
    {
      'title': 'Bandeja Paisa Colombiana',
      'description': 'El plato más tradicional de Colombia con todos sus componentes',
      'imageUrl': 'https://images.unsplash.com/photo-1604908176997-125f25cc6f3d?w=500',
      'authorId': 'chef-colombia',
      'authorName': 'Chef Luis Medellín',
      'ingredients': [
        'Frijoles rojos secos - 2 tazas',
        'Carne molida - 300g',
        'Chicharrón de cerdo - 200g',
        'Chorizo antioqueño - 150g',
        'Morcilla - 150g',
        'Huevos - 2 unidades',
        'Plátano maduro - 2 unidades',
        'Arroz blanco - 2 tazas',
        'Aguacate - 1 unidad grande',
        'Arepa - 2 unidades',
        'Hogao (guiso) para los frijoles'
      ],
      'instructions': [
        'Dejar los frijoles en remojo desde la noche anterior',
        'Cocinar los frijoles con sal hasta que estén tiernos',
        'Preparar el hogao con cebolla, tomate y especias',
        'Agregar el hogao a los frijoles y cocinar 15 minutos más',
        'Cocinar la carne molida con cebolla y condimentos',
        'Freír el chicharrón hasta que esté crujiente',
        'Asar el chorizo y la morcilla',
        'Freír los huevos',
        'Cortar el plátano en tajadas y freír',
        'Preparar arroz blanco',
        'Servir todos los componentes en una bandeja grande',
        'Acompañar con aguacate en tajadas y arepa'
      ],
      'preparationTime': 60,
      'cookingTime': 120,
      'servings': 2,
      'difficulty': 'Intermedio',
      'region': 'Colombia',
      'tags': ['Colombiano', 'Bandeja Paisa', 'Tradicional', 'Completo', 'Abundante'],
      'categories': ['Almuerzo', 'Plato Principal'],
      'isPublic': true,
      'rating': 4.9,
      'reviewsCount': 41,
      'likedBy': [],
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    },
    {
      'title': 'Tacos al Pastor Mexicanos',
      'description': 'Tacos al pastor auténticos con carne marinada y piña',
      'imageUrl': 'https://images.unsplash.com/photo-1565299624946-b28f40a0ca4b?w=500',
      'authorId': 'chef-mexico',
      'authorName': 'Chef Roberto Ciudad de México',
      'ingredients': [
        'Carne de cerdo (pierna) - 1kg',
        'Tortillas de maíz - 16 unidades',
        'Piña fresca - 1/4 de piña',
        'Cebolla blanca - 1 unidad',
        'Cilantro fresco - 1 manojo',
        'Limones - 4 unidades',
        'Salsa verde - 200ml',
        'Salsa roja - 200ml',
        'Adobo para pastor (chiles, especias)',
        'Aceite vegetal'
      ],
      'instructions': [
        'Marinar la carne con el adobo de chiles por 4 horas mínimo',
        'Cortar la carne marinada en trozos medianos',
        'Calentar una plancha o sartén grande',
        'Cocinar la carne hasta que esté dorada y crujiente',
        'Picar finamente la cebolla y el cilantro',
        'Cortar la piña en cubitos pequeños',
        'Calentar las tortillas en un comal',
        'Servir la carne en las tortillas',
        'Agregar piña, cebolla y cilantro al gusto',
        'Acompañar con salsas y limón',
        'Servir inmediatamente mientras están calientes'
      ],
      'preparationTime': 30,
      'cookingTime': 25,
      'servings': 4,
      'difficulty': 'Intermedio',
      'region': 'México',
      'tags': ['Mexicano', 'Tacos', 'Pastor', 'Cerdo', 'Piña'],
      'categories': ['Almuerzo', 'Cena', 'Antojo'],
      'isPublic': true,
      'rating': 4.8,
      'reviewsCount': 35,
      'likedBy': [],
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    },
    {
      'title': 'Asado Argentino Completo',
      'description': 'Asado tradicional argentino con cortes premium y chimichurri',
      'imageUrl': 'https://images.unsplash.com/photo-1558030006-450675393462?w=500',
      'authorId': 'chef-argentina',
      'authorName': 'Chef Eduardo Rosario',
      'ingredients': [
        'Tira de asado - 1kg',
        'Vacío - 800g',
        'Chorizo parrillero - 400g',
        'Morcilla - 300g',
        'Sal gruesa parrillera',
        'Para el chimichurri:',
        'Perejil fresco - 1 taza',
        'Orégano seco - 2 cucharadas',
        'Ajo - 4 dientes',
        'Aceite de oliva - 1/2 taza',
        'Vinagre de vino tinto - 1/4 taza',
        'Ají molido - 1 cucharadita'
      ],
      'instructions': [
        'Preparar el fuego con carbón y leña, dejar que se forme brasa',
        'Salar la carne con sal gruesa 30 minutos antes',
        'Para el chimichurri: picar finamente perejil y ajo',
        'Mezclar con orégano, aceite, vinagre y ají molido',
        'Dejar reposar el chimichurri al menos 1 hora',
        'Comenzar cocinando los embutidos',
        'Poner la tira de asado del lado del hueso primero',
        'Cocinar el vacío sellando bien ambos lados',
        'Dar vuelta la carne solo una vez',
        'Cocinar hasta el punto deseado (jugoso por dentro)',
        'Dejar reposar la carne 5 minutos antes de cortar',
        'Servir con chimichurri y ensalada'
      ],
      'preparationTime': 45,
      'cookingTime': 90,
      'servings': 6,
      'difficulty': 'Intermedio',
      'region': 'Argentina',
      'tags': ['Argentino', 'Asado', 'Parrilla', 'Carne', 'Chimichurri'],
      'categories': ['Almuerzo', 'Cena', 'Especial'],
      'isPublic': true,
      'rating': 4.9,
      'reviewsCount': 28,
      'likedBy': [],
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    }
  ];

  try {
    for (int i = 0; i < recetas.length; i++) {
      await firestore.collection('recipes').add(recetas[i]);
      print('✅ Receta ${i + 1}/${recetas.length} agregada: ${recetas[i]['title']}');
    }
    
    print('🎉 ¡Todas las recetas han sido agregadas exitosamente a Firebase!');
    print('📊 Total de recetas agregadas: ${recetas.length}');
    
  } catch (e) {
    print('❌ Error al agregar recetas: $e');
  }
}
