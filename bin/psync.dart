import 'package:libpq_dart/libpq_dart.dart';
import 'package:psync/psync_dart.dart';

// dbtoyaml -H localhost -p 5435 -U dart -W -n public -o teste.yaml --no-owner --no-privileges banco_teste 
// yamltodb -H localhost -p 5435 -U dart -W -n public -o teste.sql banco_teste2 teste.yaml
// psql -h localhost -p 5435 -U dart -W -f teste.sql  banco_teste2
void main(List<String> args) {
  final source = LibPq(
      'user=dart password=dart host=127.0.0.1 dbname=banco_teste port=5435');

  final target = LibPq(
      'user=dart password=dart host=127.0.0.1 dbname=banco_teste2 port=5435');

  // final psync = PSync(source, target);
  // psync.start();


}
