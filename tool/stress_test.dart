import 'dart:convert';
import 'dart:io';
import 'package:boty_frog/core/logger.dart';
import 'package:logging/logging.dart';

Future<void> main(List<String> args) async {
  initLogger();
  final logger = Logger('StressTest');

  if (args.isEmpty) {
    logger.severe('Uso: dart test/stress_test.dart <URL_DE_CLOUD_RUN>');
    exit(1);
  }

  final urlString = args[0];
  final webhookUrl = urlString.endsWith('/')
      ? '${urlString}webhook'
      : '$urlString/webhook';
  final url = Uri.parse(webhookUrl);
  final client = HttpClient();

  final preguntas = [
    'Hola, ¿tienen este vestido en talla M?',
    '¿Cuáles son sus métodos de pago?',
    '¿Tienen envíos a provincia?',
    '¿Tienen tienda física?',
    'Hola, me gustaría saber si tienen faldas en jean',
    '¿Tienen catálogo disponible?',
    '¿Cómo es el proceso de devolución?',
    'Quiero saber el precio del pantalón de Instagram',
    'Hola, ¿tienen el enterizo negro en talla S?',
    '¿Hacen envíos a todo el Perú?',
    '¿Cuánto cuesta el envío a San Miguel?',
    'Hola, ¿qué colores tienen disponibles para la blusa blanca?',
    '¿Tienen descuento si llevo más de 3 prendas?',
    '¿Tienen la guía de tallas para las faldas?',
    '¿Puedo pagar al recibir el producto?',
    'Hola, ¿el vestido rojo viene con cinturón?',
    '¿Qué material es el enterizo de flores?',
    '¿Se puede hacer cambio si la talla no me queda?',
    'Hola, buenas tardes, ¿tienen stock del blazer celeste?',
    '¿Aceptan pagos con tarjeta de crédito?',
    '¿Tienen probadores en su tienda física?',
    '¿Cuál es el horario de atención de la tienda?',
    'Hola, ¿tienen pantalones palazzo en color beige?',
    '¿Tienen alguna oferta o liquidación vigente?',
    'Quiero comprar el vestido verde, ¿cómo hago el pedido?',
    'Hola, ¿qué tela es la casaca denim?',
    '¿Tienen envíos express para el mismo día?',
    '¿Aceptan transferencias bancarias del BCP?',
    'Hola, ¿tienen stock en talla L de la falda plisada?',
    '¿Hacen entregas en estaciones del Metropolitano?',
    '¿Tienen vestidos de noche en su catálogo?',
    'Hola, ¿este conjunto es de una sola pieza o viene por separado?',
    '¿El pantalón jean es rígido o tiene stretch?',
    '¿Cuánto tiempo demora en llegar a Arequipa?',
    'Hola, ¿tienen politos básicos de algodón?',
    '¿Tienen showroom donde pueda ver la ropa?',
    '¿Cuál es el precio de la blusa con encaje?',
    'Hola, ¿tienen la casaca de cuero sintético en talla XL?',
    '¿Hacen envíos a domicilio en Lima?',
    '¿Aceptan Yape o Plin para el pago?',
    'Hola, ¿tienen tops deportivos en catálogo?',
    '¿Tienen shorts de lino para el verano?',
    '¿El color del vestido es exactamente igual al de la foto?',
    'Hola, ¿se encoge la tela después del primer lavado?',
    '¿Tienen vestidos de baño o bikinis?',
    '¿Puedo separar una prenda y pagar el saldo después?',
    'Hola, ¿tienen blusas manga larga para la oficina?',
    '¿Venden ropa al por mayor o solo al por menor?',
    '¿Tienen stock del abrigo de lana para el invierno?',
    'Hola, quiero saber si tienen stock del crop top rosado en talla XS',
  ];

  const totalClientes = 50;
  final stopwatch = Stopwatch()..start();

  final futures = List.generate(totalClientes, (index) async {
    final clienteId = '519999999${index.toString().padLeft(2, '0')}';
    final mensaje = preguntas[index % preguntas.length];

    final payload = {
      'entry': [
        {
          'changes': [
            {
              'value': {
                'messaging_product': 'whatsapp',
                'metadata': {
                  'display_phone_number': '16505553333',
                  'phone_number_id': '900387823150921',
                },
                'contacts': [
                  {
                    'profile': {'name': 'Cliente Simulado $index'},
                    'wa_id': clienteId,
                  },
                ],
                'messages': [
                  {
                    'from': clienteId,
                    'id': 'wamid.simulatedmessage$index',
                    'timestamp': (DateTime.now().millisecondsSinceEpoch ~/ 1000)
                        .toString(),
                    'text': {'body': mensaje},
                    'type': 'text',
                  },
                ],
              },
              'field': 'messages',
            },
          ],
        },
      ],
    };

    final requestStopwatch = Stopwatch()..start();
    try {
      final request = await client.postUrl(url);
      request.headers.contentType = ContentType.json;
      request.write(jsonEncode(payload));

      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();
      requestStopwatch.stop();

      logger.info(
        'Cliente $index: Status ${response.statusCode} | '
        'Tiempo: ${requestStopwatch.elapsedMilliseconds}ms | '
        'Respuesta: $responseBody',
      );
      return response.statusCode == 200;
    } catch (e) {
      requestStopwatch.stop();
      logger.severe(
        'Cliente $index: Error -> $e | '
        'Tiempo: ${requestStopwatch.elapsedMilliseconds}ms',
      );
      return false;
    }
  });

  final resultados = await Future.wait(futures);
  stopwatch.stop();

  final exitosas = resultados.where((r) => r).length;
  logger
    ..info('--- Resumen de Prueba de Carga ---')
    ..info('Total de peticiones: $totalClientes')
    ..info('Exitosas: $exitosas')
    ..info('Fallidas: ${totalClientes - exitosas}')
    ..info('Tiempo total de ejecución: ${stopwatch.elapsedMilliseconds}ms');

  client.close();
}
