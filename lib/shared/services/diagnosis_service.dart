export 'diagnosis_service_stub.dart'
    if (dart.library.io) 'diagnosis_service_mobile.dart'
    if (dart.library.html) 'diagnosis_service_web.dart';
