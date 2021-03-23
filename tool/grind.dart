import 'dart:async';
import 'dart:io';

import 'package:grinder/grinder.dart';
import 'package:mustache_template/mustache.dart';
import 'package:path/path.dart' as path;

main(args) => grind(args);

@DefaultTask('build web app')
@Depends(test)
build() => runAsync('flutter', arguments: ['build', 'web']);

@Task('get dependencies')
Future<void> get() => runAsync('flutter', arguments: ['pub', 'get']);

@Task('run tests')
Future<void> test() => runAsync('flutter', arguments: ['test']);

@Task('copy build to destination (default: --dest=public/develop)')
Future<void> stage() async {
  final args = context.invocation.arguments;
  final destination = args.getOption('dest') ?? 'public/develop';
  final baseHref = args.getOption('base-href') ?? 'build/develop';

  final indexPath =
      path.join(Directory.current.path, 'templates', 'index.html');
  final index = await File(indexPath).readAsString();

  final template = Template(index);
  final output = template.renderString({'base_href': baseHref});

  copyDirectory(Directory('build/web'), Directory(destination));
  await File('$destination/index.html').writeAsString(output);
}
