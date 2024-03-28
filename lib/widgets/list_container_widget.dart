import 'package:flutter/material.dart';

class ListContainerWidget extends StatelessWidget {
  final VoidCallback? onTap;
  final String? title;
  final List<Widget> children;

  const ListContainerWidget({
    super.key,
    this.onTap,
    this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    List<Widget> columnChildren = [];

    for (var i = 0; i < children.length; i++) {
      columnChildren.add(
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(i == 0 ? 32.0 : 0.0),
              bottom: Radius.circular(i == children.length - 1 ? 32.0 : 0.0),
            ),
            child: children[i],
          ),
        ),
      );

      if (i < children.length - 1) {
        columnChildren.add(Divider(height: 1, thickness: 1, color: Colors.grey));
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(40.0, 8.0, 16.0, 0.0),
            child: Text(
              title!,
              style: const TextStyle(
                fontSize: 12.0,
                color: Colors.grey,
              ),
            ),
          ),
        ],
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(32.0),
          child: Container(
            padding: EdgeInsets.all(16.0),
            margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(title != null ? 32.0 : 32.0),
                bottom: const Radius.circular(32.0),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: columnChildren,
            ),
          ),
        ),
      ],
    );
  }
}

