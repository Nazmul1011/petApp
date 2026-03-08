//  This is updated version for this app
//  This is updated version for this app
import 'package:flutter/material.dart';

import '../../../core/themes/app_colors.dart';
import '../../../core/themes/app_typography.dart';
import '../../helpers/form_field_validators.dart';
import '../../helpers/input_formatter.dart';

enum FormFieldType {
  general,
  name,
  phone,
  email,
  password,
  confirmPassword,
  number,
  dob,
  readOnlyDisplay,
}

class AppTextFormField extends StatefulWidget {
  final String? label;
  final TextEditingController? controller;
  final String? initialValue;
  final FormFieldType type;
  final String? hintText;
  final TextStyle? hintStyle;
  final String? helperText;
  final TextStyle? helperStyle;

  // Icons
  final Widget? prefixIcon;
  final bool showIsoCodeOnly;
  final String isoCode;
  final Widget? suffixIcon;
  final Color? prefixIconColor;
  final Color? suffixIconColor;

  /// NEW: allow turning prefix icon ON/OFF
  final bool showPrefixIcon;

  final bool obscureText;
  final int? maxLines;

  /// Word limit
  final int? maxLength;

  /// Counter show/hide
  final bool showCounter;

  final TextInputAction? textInputAction;
  final Function(String)? onChanged;
  final Function()? onTap;
  final Function(PointerDownEvent)? onTapOutside;
  final String? Function(String?)? validator;
  final FocusNode? focusNode;
  final bool readOnly;
  final bool enabled;
  final TextCapitalization textCapitalization;

  final double borderRadius;

  const AppTextFormField({
    super.key,
    this.label,
    this.controller,
    this.initialValue,
    this.type = FormFieldType.general,
    this.hintText,
    this.hintStyle,
    this.helperText,
    this.helperStyle,
    this.prefixIcon,
    this.showIsoCodeOnly = false,
    this.isoCode = '880',
    this.suffixIcon,
    this.obscureText = false,
    this.maxLines = 1,
    this.maxLength,
    this.textInputAction,
    this.onChanged,
    this.onTap,
    this.onTapOutside,
    this.validator,
    this.focusNode,
    this.readOnly = false,
    this.enabled = true,
    this.textCapitalization = TextCapitalization.none,
    this.prefixIconColor = AppColors.primaryColor,
    this.suffixIconColor = AppColors.primaryColor,
    this.borderRadius = 14,

    /// NEW defaults
    this.showPrefixIcon = true,
    this.showCounter = false,
  });

  @override
  State<AppTextFormField> createState() => _AppTextFormFieldState();
}

class _AppTextFormFieldState extends State<AppTextFormField> {
  late bool isObscured;
  late FocusNode _focusNode;
  bool _ownsFocusNode = false;

  @override
  void initState() {
    super.initState();
    isObscured = widget.obscureText;

    if (widget.focusNode != null) {
      _focusNode = widget.focusNode!;
    } else {
      _focusNode = FocusNode();
      _ownsFocusNode = true;
    }

    _focusNode.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    if (_ownsFocusNode) _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.controller != null && widget.initialValue != null) {
      throw FlutterError(
        'TheTextFormField cannot have both controller and initialValue.',
      );
    }

    if (widget.type == FormFieldType.readOnlyDisplay) {
      return TextFormField(
        controller: widget.controller,
        readOnly: true,
        style: const TextStyle(
          color: Color(0xFF20262E),
          fontSize: 18,
          fontWeight: FontWeight.w400,
          height: 1,
          letterSpacing: 0.50,
        ),
        decoration: const InputDecoration(
          border: UnderlineInputBorder(borderSide: BorderSide.none),
          focusedBorder: UnderlineInputBorder(borderSide: BorderSide.none),
          enabledBorder: UnderlineInputBorder(borderSide: BorderSide.none),
          labelText: '',
          contentPadding: EdgeInsets.zero,
        ),
      );
    }

    // ===== Your spec =====
    const padX = 12.0;
    const padY = 8.0;
    const gap = 0.0; // handle gap between the the label text and the hint text

    const labelColor = Color(0xFF0A0A0A);
    const hintColor = Color(0xFFA1A1A1);

    final labelStyle = AppTypography.bodyXs.copyWith(color: labelColor);
    final hintStyle =
        widget.hintStyle ?? AppTypography.bodySm.copyWith(color: hintColor);
    final valueStyle = AppTypography.bodySm.copyWith(
      color: Theme.of(context).colorScheme.onSurface,
    );

    const borderColor = Color(0xFFD8D9DD);

    final isFocused = _focusNode.hasFocus;
    final border = Border.all(
      color: isFocused ? AppColors.primaryColor : borderColor,
      width: isFocused ? 2 : 1,
    );

    final radius = BorderRadius.circular(widget.borderRadius);

    /// NEW: prefix icon can be turned off
    final Widget? prefix = widget.showPrefixIcon
        ? (widget.prefixIcon ??
              getDefaultPrefixIcon(widget.type, widget.prefixIconColor))
        : null;

    final Widget? suffix =
        (widget.type == FormFieldType.password ||
            widget.type == FormFieldType.confirmPassword)
        ? IconButton(
            icon: Icon(
              isObscured ? Icons.visibility : Icons.visibility_off,
              color: widget.suffixIconColor,
            ),
            onPressed: () => setState(() => isObscured = !isObscured),
          )
        : widget.suffixIcon;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: border,
        borderRadius: radius,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: padX, vertical: padY),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (prefix != null) ...[
              Padding(padding: const EdgeInsets.only(top: 2), child: prefix),
              const SizedBox(width: 8),
            ],

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.label != null)
                    Text(widget.label!, style: labelStyle),
                  const SizedBox(height: gap),

                  TextFormField(
                    controller: widget.controller,
                    initialValue: widget.controller == null
                        ? widget.initialValue
                        : null,
                    focusNode: _focusNode,
                    readOnly: widget.readOnly,
                    enabled: widget.enabled,
                    keyboardType: getKeyboardType(widget.type),
                    textCapitalization: widget.textCapitalization,
                    obscureText:
                        (widget.type == FormFieldType.password ||
                            widget.type == FormFieldType.confirmPassword)
                        ? isObscured
                        : widget.obscureText,
                    maxLines: widget.maxLines,
                    maxLength: widget.maxLength,
                    textInputAction: widget.textInputAction,

                    // keep your logic
                    onChanged: (value) {
                      widget.onChanged?.call(value);
                      final trimmed = value.trim();
                      if (widget.type == FormFieldType.phone) {
                        final cleaned = trimmed.startsWith('0')
                            ? trimmed.substring(1)
                            : trimmed;
                        if (cleaned != trimmed) {
                          widget.controller?.text = cleaned;
                          widget.controller?.selection =
                              TextSelection.collapsed(offset: cleaned.length);
                        }
                        final isValidBDPhone = RegExp(
                          r'^(1)[3-9]\d{8}$',
                        ).hasMatch(cleaned);
                        if (isValidBDPhone) {
                          FocusManager.instance.primaryFocus?.unfocus();
                        }
                      }
                    },

                    onTap: widget.onTap,
                    onTapOutside:
                        widget.onTapOutside ??
                        (_) => FocusManager.instance.primaryFocus?.unfocus(),
                    inputFormatters: getInputFormatters(widget.type),
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator:
                        widget.validator ??
                        (value) => validateField(value, widget.type),

                    style: valueStyle,

                    // NEW: counter show/hide
                    buildCounter: widget.showCounter
                        ? (
                            context, {
                            required currentLength,
                            required isFocused,
                            maxLength,
                          }) {
                            if (maxLength == null) return null;
                            return Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Text(
                                '$currentLength/$maxLength',
                                style: AppTypography.bodyXs.copyWith(
                                  color: const Color(0xFFA1A1A1),
                                ),
                              ),
                            );
                          }
                        : (
                            context, {
                            required currentLength,
                            required isFocused,
                            maxLength,
                          }) => null,

                    decoration:
                        InputDecoration.collapsed(
                          hintText: widget.hintText,
                          hintStyle: hintStyle,
                        ).copyWith(
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          disabledBorder: InputBorder.none,
                        ),
                  ),

                  if (widget.helperText != null) ...[
                    const SizedBox(height: 6),
                    Text(widget.helperText!, style: widget.helperStyle),
                  ],
                ],
              ),
            ),

            if (suffix != null) ...[
              const SizedBox(width: 6),
              Padding(padding: const EdgeInsets.only(top: 2), child: suffix),
            ],
          ],
        ),
      ),
    );
  }

  TextInputType getKeyboardType(FormFieldType type) {
    switch (type) {
      case FormFieldType.name:
        return TextInputType.name;
      case FormFieldType.phone:
        return TextInputType.phone;
      case FormFieldType.email:
        return TextInputType.emailAddress;
      case FormFieldType.number:
        return TextInputType.number;
      case FormFieldType.password:
        return TextInputType.visiblePassword;
      default:
        return TextInputType.text;
    }
  }

  Widget? getDefaultPrefixIcon(FormFieldType type, Color? iconColor) {
    switch (type) {
      case FormFieldType.name:
        return Icon(Icons.person, color: iconColor, size: 20);
      case FormFieldType.phone:
        return widget.showIsoCodeOnly
            ? Text(
                widget.isoCode,
                style: AppTypography.bodySm.copyWith(color: Colors.black54),
              )
            : Icon(Icons.phone, color: iconColor, size: 20);
      case FormFieldType.email:
        return Icon(Icons.email, color: iconColor, size: 20);
      case FormFieldType.password:
      case FormFieldType.confirmPassword:
        return Icon(Icons.lock, color: iconColor, size: 20);
      case FormFieldType.number:
        return Icon(Icons.numbers, color: iconColor, size: 20);
      default:
        return null;
    }
  }
}


// Example : 

// AppTextFormField(
//             label: "Type",
//             hintText: "Dog",
//             maxLength: 5,
//             showPrefixIcon: false,  // without the icon
//             type: FormFieldType.name, // can use number for the number field
//           ),