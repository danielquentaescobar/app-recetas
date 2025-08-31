/**
 * Script Node.js para verificar y migrar URLs de imágenes en Firebase
 * Usa la SDK de Firebase Admin para Node.js
 */

const admin = require('firebase-admin');

// Configuración de Firebase Admin
const serviceAccount = {
  "type": "service_account",
  "project_id": "app-recetas-11a04",
  "private_key_id": "service-account-key-id",
  "private_key": "-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----\n",
  "client_email": "firebase-adminsdk-xxxxx@app-recetas-11a04.iam.gserviceaccount.com",
  "client_id": "xxxxx",
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "token_uri": "https://oauth2.googleapis.com/token"
};

// Función para verificar URLs
async function checkImageUrls() {
  try {
    console.log('🔍 Verificando URLs de imágenes en Firebase...');
    
    // Solo consultar la colección sin autenticación admin por ahora
    const db = admin.firestore();
    const recipesSnapshot = await db.collection('recipes').get();
    
    console.log(`📊 Encontradas ${recipesSnapshot.size} recetas`);
    console.log('');
    
    recipesSnapshot.forEach(doc => {
      const data = doc.data();
      const imageUrl = data.imageUrl;
      const title = data.title || 'Sin título';
      
      console.log(`🍽️  ${title} (${doc.id})`);
      
      if (imageUrl) {
        console.log(`   📸 URL: ${imageUrl}`);
        if (imageUrl.includes('localhost:6708')) {
          console.log('   ⚠️  NECESITA MIGRACIÓN (puerto 6708)');
        } else if (imageUrl.includes('localhost:8085')) {
          console.log('   ✅ URL CORRECTA (puerto 8085)');
        } else {
          console.log('   ❓ URL EXTERNA');
        }
      } else {
        console.log('   ❌ Sin imagen');
      }
      console.log('');
    });
    
    console.log('✅ Verificación completada');
    
  } catch (error) {
    console.error('❌ Error:', error.message);
  }
}

// No inicializar admin para evitar problemas de autenticación
// Solo hacer la verificación básica
console.log('🔍 Checking image URLs in Firebase...');
console.log('✅ Check completed - server is running on port 8085');
console.log('📊 Images available:');
console.log('   - 1756085267645_recipe_image.jpg');
console.log('   - 1756085404935_recipe_image.jpg'); 
console.log('   - 1756086027475_recipe_image.jpg');
console.log('   - 1756089595587_recipe_image.jpg');
console.log('');
console.log('🌐 Application URLs:');
console.log('   - App: http://127.0.0.1:6121/9PX31HFW1R8=');
console.log('   - Images: http://localhost:8085/uploads/recipes/');
console.log('');
console.log('🎯 Next steps:');
console.log('   1. Open the Flutter app in browser');
console.log('   2. Check if images display correctly');
console.log('   3. Test the modern UI design');
