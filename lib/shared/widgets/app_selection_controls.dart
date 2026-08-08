import 'package:flutter/material.dart';

class AppSwitch extends StatelessWidget {
  const AppSwitch({
    required this.label,
    required this.value,
    required this.onChanged,
    this.subtitle,
    super.key,
  });

  final String label;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile.adaptive(
      title: Text(label),
      subtitle: subtitle == null ? null : Text(subtitle!),
      value: value,
      onChanged: onChanged,
    );
  }
}

class AppCheckbox extends StatelessWidget {
  const AppCheckbox({
    required this.label,
    required this.value,
    required this.onChanged,
    this.subtitle,
    this.tristate = false,
    super.key,
  });

  final String label;
  final String? subtitle;
  final bool? value;
  final ValueChanged<bool?>? onChanged;
  final bool tristate;

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      title: Text(label),
      subtitle: subtitle == null ? null : Text(subtitle!),
      value: value,
      tristate: tristate,
      onChanged: onChanged,
      controlAffinity: ListTileControlAffinity.leading,
    );
  }
}

class AppRadio<T> extends StatelessWidget {
  const AppRadio({
    required this.label,
    required this.value,
    required this.groupValue,
    required this.onChanged,
    this.subtitle,
    super.key,
  });

  final String label;
  final String? subtitle;
  final T value;
  final T? groupValue;
  final ValueChanged<T?>? onChanged;

  @override
  Widget build(BuildContext context) {
    return RadioGroup<T>(
      groupValue: groupValue,
      onChanged: (selectedValue) => onChanged?.call(selectedValue),
      child: RadioListTile<T>(
        enabled: onChanged != null,
        title: Text(label),
        subtitle: subtitle == null ? null : Text(subtitle!),
        value: value,
      ),
    );
  }
}
