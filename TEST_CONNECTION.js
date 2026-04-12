/**
 * SCRIPT DE PRUEBA DE INFRAESTRUCTURA
 * Este script verifica que tanto Supabase como Redis estén respondiendo correctamente.
 */
const { createClient } = require('@supabase/supabase-js');
const redis = require('redis');
require('dotenv').config();

// 1. Configuración desde el archivo .env
const supabaseUrl = process.env.SUPABASE_URL || 'http://127.0.0.1:54321';
const supabaseKey = process.env.SUPABASE_SERVICE_ROLE_KEY;
const redisUrl = process.env.REDIS_URL || 'redis://localhost:6379';

async function runTest() {
    console.log('🚀 Iniciando pruebas de infraestructura...\n');

    // --- PRUEBA DE SUPABASE ---
    console.log('📡 Probando conexión con Supabase...');
    const supabase = createClient(supabaseUrl, supabaseKey);

    try {
        const { data, error } = await supabase.from('users').select('count', { count: 'exact', head: true });
        if (error) throw error;
        console.log('✅ Supabase: Conexión exitosa. Tablas accesibles.\n');
    } catch (err) {
        console.error('❌ Supabase: Error de conexión:', err.message);
    }

    // --- PRUEBA DE REDIS ---
    console.log('🧠 Probando conexión con Redis (Caché de IA)...');
    const redisClient = redis.createClient({ url: redisUrl });

    try {
        await redisClient.connect();
        await redisClient.set('test_key', 'Conexión OK');
        const value = await redisClient.get('test_key');
        if (value === 'Conexión OK') {
            console.log('✅ Redis: Conexión exitosa. Lectura/Escritura OK.\n');
        }
        await redisClient.quit();
    } catch (err) {
        console.error('❌ Redis: Error de conexión:', err.message);
    }

    console.log('🏁 Pruebas finalizadas.');
}

if (!supabaseKey) {
    console.error('⚠️ Error: No se encontró SUPABASE_SERVICE_ROLE_KEY en el archivo .env');
    console.log('Por favor, ejecuta "npx supabase status" y copia la service_role key al archivo .env');
} else {
    runTest();
}
