import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:schoolarc/utils/extensions/context_extension.dart';

class LoginField {
  LoginField({
    required this.name,
    this.obscure = false,
    this.initialValue,
    this.autofillHints,
    this.info,
  });

  String name;
  bool obscure;
  String? info;
  Iterable<String>? autofillHints;
  String? initialValue;
}

class LoginInputScreen extends StatefulWidget {
  const LoginInputScreen({
    super.key,
    required this.fields,
    required this.actionName,
    required this.onSubmit,
    this.bottomChild,
  });

  final List<LoginField> fields;
  final String actionName;
  final void Function(List<String> fieldValues) onSubmit;
  final Widget? bottomChild;

  @override
  State<LoginInputScreen> createState() => _LoginInputScreenState();
}

class _LoginInputScreenState extends State<LoginInputScreen> {
  late List<TextEditingController> controllers = List.generate(
    widget.fields.length,
    (index) => TextEditingController(text: widget.fields[index].initialValue),
  );

  late List<bool?> obscures = widget.fields
      .map((e) => e.obscure ? true : null)
      .toList();

  late bool actionEnabled = enabled();

  @override
  void dispose() {
    for (var element in controllers) {
      element.dispose();
    }

    super.dispose();
  }

  bool enabled() {
    return controllers.where((element) => element.text == '').isEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.actionName),
      ),
      body: AutofillGroup(
        child: ListView.builder(
          itemCount:
              controllers.length + 1 + (widget.bottomChild == null ? 0 : 1),
          itemBuilder: (context, index) {
            if (index == controllers.length + 1 && widget.bottomChild != null) {
              return Center(child: widget.bottomChild);
            }
            if (index == controllers.length) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: FilledButton(
                    key: Key(widget.actionName),
                    onPressed: actionEnabled
                        ? () => widget.onSubmit(
                            controllers.map((e) => e.text).toList(),
                          )
                        : null,
                    child: Text(widget.actionName),
                  ),
                ),
              );
            }

            final field = widget.fields[index];
            final obscure = obscures[index];

            return Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      key: Key(field.name),
                      autofocus: index == 0 && !kIsWeb,
                      onChanged: (value) {
                        if (value == '') {
                          setState(() {
                            actionEnabled = false;
                          });
                        } else {
                          setState(() {
                            actionEnabled = enabled();
                          });
                        }
                      },
                      controller: controllers[index],
                      autofillHints: field.autofillHints,
                      obscureText: obscures[index] ?? false,
                      decoration: InputDecoration(
                        labelText: field.name,
                      ),
                    ),
                  ),
                  if (field.info != null)
                    ExcludeFocus(
                      child: IconButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text(field.name),
                              content: Text(field.info!),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: Text(context.loc.ok),
                                ),
                              ],
                            ),
                          );
                        },
                        icon: const Icon(Icons.info_outline),
                      ),
                    ),
                  if (obscure != null)
                    ExcludeFocus(
                      child: IconButton(
                        onPressed: () {
                          setState(() {
                            obscures[index] = !obscure;
                          });
                        },
                        icon: Icon(
                          obscure ? Icons.visibility : Icons.visibility_off,
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
