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
  });

  final List<LoginField> fields;
  final String actionName;
  final void Function(List<String> fieldValues) onSubmit;

  @override
  State<LoginInputScreen> createState() => _FirebaseLoginPageState();
}

class _FirebaseLoginPageState extends State<LoginInputScreen> {
  late List<TextEditingController> controllers = List.generate(
    widget.fields.length,
    (index) => TextEditingController(text: widget.fields[index].initialValue),
  );

  late List<bool?> obscures =
      widget.fields.map((e) => e.obscure ? true : null).toList();

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
      body: ListView.builder(
        itemCount: controllers.length + 1,
        itemBuilder: (context, index) {
          if (index == controllers.length) {
            return Center(
              child: FilledButton(
                onPressed: actionEnabled
                    ? () =>
                        widget.onSubmit(controllers.map((e) => e.text).toList())
                    : null,
                child: Text(widget.actionName),
              ),
            );
          }

          final field = widget.fields[index];
          final obscure = obscures[index];

          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    autofocus: index == 0,
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
                      contentPadding: const EdgeInsets.all(15),
                      border: const OutlineInputBorder(),
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
                                  child: Text(context.loc.ok))
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
    );
  }
}
