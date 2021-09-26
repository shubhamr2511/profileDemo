import 'package:flutter/material.dart';
import 'package:profiledemo/models/user.dart';
import 'package:profiledemo/styles.dart';

class DetailBox extends StatelessWidget {
  final String fieldName;
  final String fieldtext;
  const DetailBox(
      {this.fieldName = "default", this.fieldtext = "default", Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                    color: blue,
                    border: Border.all(),
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24))),
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  fieldName,
                  style: headline6,
                ),
              ),
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                    color: grey,
                    border: Border.all(),
                    borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(24),
                        bottomRight: Radius.circular(24))),
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  fieldtext,
                  style: subtitle2White,
                ),
              ),
            ),
          ],
        )
      ]),
    );
  }
}

class DetailButton extends StatelessWidget {
  final String text;
  final Icon icon;
  final VoidCallback? onTap;
  const DetailButton(
      {this.onTap,
      this.text = "Button",
      this.icon = const Icon(Icons.code),
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(" " + this.text, style: subtitle1),
        IconButton(
          onPressed: this.onTap,
          icon: this.icon,
          color: white,
          highlightColor: blue,
          iconSize: 30,
        ),
      ],
    );
  }
}

class MyTextField extends StatelessWidget {
  final TextEditingController textEditingController = new TextEditingController();
  final FocusNode focusNode = new FocusNode();

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: textEditingController,
      focusNode: focusNode,
      style: bodyText2White38,
      decoration: InputDecoration(
          fillColor: focusNode.hasFocus ? Colors.black : darkGrey,
          filled: true,
          alignLabelWithHint: true,
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: almostWhite,
            ),
            borderRadius: BorderRadius.circular(6.0),
          ),
          labelText:
              focusNode.hasFocus ? 'tell Something about yourself...' : null,
          labelStyle: focusNode.hasFocus ? bodyText2 : null,
          hintText:
              focusNode.hasFocus ? null : 'tell Something about yourself...',
          hintStyle: bodyText2White38),
    );
  }
}
