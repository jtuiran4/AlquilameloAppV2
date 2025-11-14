// Script de migración para agregar campos resolutionNotes y completedAt
// a las consultas existentes en Firestore

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../firebase_options.dart';

Future<void> migrateInquiries() async {
  print('🚀 Iniciando migración de consultas...');
  
  try {
    // Inicializar Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    
    final firestore = FirebaseFirestore.instance;
    
    // Obtener todas las consultas
    final snapshot = await firestore.collection('contacts').get();
    
    print('📊 Total de consultas encontradas: ${snapshot.docs.length}');
    
    int updated = 0;
    int skipped = 0;
    
    // Actualizar cada documento
    for (var doc in snapshot.docs) {
      final data = doc.data();
      
      // Verificar si ya tiene los campos
      if (data.containsKey('resolutionNotes') && data.containsKey('completedAt')) {
        print('⏭️  Consulta ${doc.id} ya tiene los campos, saltando...');
        skipped++;
        continue;
      }
      
      // Agregar los campos con valores por defecto
      Map<String, dynamic> updateData = {};
      
      if (!data.containsKey('resolutionNotes')) {
        updateData['resolutionNotes'] = null;
      }
      
      if (!data.containsKey('completedAt')) {
        updateData['completedAt'] = null;
      }
      
      if (updateData.isNotEmpty) {
        await doc.reference.update(updateData);
        print('✅ Actualizada consulta ${doc.id}');
        updated++;
      }
    }
    
    print('\n✨ Migración completada:');
    print('   ✅ Actualizadas: $updated');
    print('   ⏭️  Saltadas: $skipped');
    print('   📊 Total: ${snapshot.docs.length}');
    
  } catch (e) {
    print('❌ Error en la migración: $e');
  }
}

void main() async {
  await migrateInquiries();
}
