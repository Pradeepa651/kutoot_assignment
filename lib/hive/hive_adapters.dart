import 'package:hive_ce/hive_ce.dart';
import '../model/task.dart' show TaskList, Task;

@GenerateAdapters([AdapterSpec<Task>()])
part 'hive_adapters.g.dart';
