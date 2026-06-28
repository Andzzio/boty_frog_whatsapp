import 'package:boty_frog/data/datasources/business_info_firestore_datasource.dart';
import 'package:firebase_admin_sdk/firebase_admin_sdk.dart';
import 'package:google_cloud_firestore/google_cloud_firestore.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class MockFirebaseApp extends Mock implements FirebaseApp {}

class MockFirestore extends Mock implements Firestore {}

class MockCollectionReference extends Mock
    implements CollectionReference<Map<String, dynamic>> {
  @override
  CollectionReference<R> withConverter<R>({
    Object? fromFirestore,
    Object? toFirestore,
  }) {
    throw UnimplementedError();
  }

  @override
  bool operator ==(Object other) => identical(this, other);

  @override
  int get hashCode => identityHashCode(this);
}

class MockDocumentReference extends Mock
    implements DocumentReference<Map<String, dynamic>> {}

class MockDocumentSnapshot extends Mock
    implements DocumentSnapshot<Map<String, dynamic>> {}

void main() {
  late MockFirebaseApp mockFirebaseApp;
  late MockFirestore mockFirestore;
  late MockCollectionReference mockBusinessesCollection;
  late MockDocumentReference mockBusinessDoc;
  late MockDocumentSnapshot mockBusinessSnapshot;
  late BusinessInfoFirestoreDatasource datasource;

  setUp(() {
    mockFirebaseApp = MockFirebaseApp();
    mockFirestore = MockFirestore();
    mockBusinessesCollection = MockCollectionReference();
    mockBusinessDoc = MockDocumentReference();
    mockBusinessSnapshot = MockDocumentSnapshot();

    datasource = BusinessInfoFirestoreDatasource(mockFirebaseApp);

    when(() => mockFirebaseApp.firestore()).thenReturn(mockFirestore);
  });

  test(
      'should return BusinessInfoEntity with payment methods '
      'and shipping zones from Firestore', () async {
    const businessId = 'biz_123';

    when(() => mockFirestore.collection('businesses'))
        .thenReturn(mockBusinessesCollection);
    when(() => mockBusinessesCollection.doc(businessId))
        .thenReturn(mockBusinessDoc);
    when(() => mockBusinessDoc.get())
        .thenAnswer((_) async => mockBusinessSnapshot);
    when(() => mockBusinessSnapshot.data()).thenReturn({
      'paymentMethods': [
        {
          'name': 'Yape',
          'type': 'efectivo',
          'description': 'Celular 999888777',
        },
        {
          'name': 'Plin',
          'type': 'efectivo',
          'description': 'Celular 999888777',
        },
        {
          'name': 'Transferencia',
          'type': 'transferencia',
          'description': 'BCP CCI...',
        },
      ],
      'deliveryMethods': [
        {
          'name': 'Lima Metropolitana',
          'price': 10,
          'description': 'Envío rápido a domicilio',
        }
      ],
    });

    final result = await datasource.getBusinessInfo(businessId);

    expect(
      result.paymentMethods,
      containsAll([
        'Yape (Celular 999888777)',
        'Plin (Celular 999888777)',
        'Transferencia (BCP CCI...)',
      ]),
    );
    expect(result.shippingZones, hasLength(1));
    expect(result.shippingZones.first.id, 'Lima Metropolitana');
    expect(result.shippingZones.first.name, 'Lima Metropolitana');
    expect(result.shippingZones.first.price, 10.0);
    expect(
      result.shippingZones.first.description,
      'Envío rápido a domicilio',
    );
  });
}
