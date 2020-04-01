import 'package:flutter/material.dart';
import 'package:ytrendd/models/country.dart';
import 'package:ytrendd/providers/countries_provider.dart';
import 'package:provider/provider.dart';

class SelectedCountryTile extends StatefulWidget {
  final Country country;

  SelectedCountryTile(this.country);

  @override
  _SelectedCountryTileState createState() => _SelectedCountryTileState();
}

class _SelectedCountryTileState extends State<SelectedCountryTile>
    with TickerProviderStateMixin {
  Widget build(BuildContext context) {
    final tile = ListTile(
      leading: Checkbox(
        value: widget.country.selected,
        onChanged: (bool newValue) {
          Provider.of<CountriesProvider>(context, listen: false)
              .onSelectCountry(widget.country);
        },
      ),
      title: Row(
        children: <Widget>[
          Text(
            '${widget.country.emoji}',
            style: TextStyle(
              fontFamily: 'NotoColorEmoji',
            ),
          ),
          SizedBox(width: 5.0),
          Text('${widget.country.name}'),
        ],
      ),
      trailing: Icon(Icons.menu),
    );

    final dragTarget = DragTarget<Country>(
      onWillAccept: (sourceCountry) {
        return true;
      },
      onAccept: (sourceCountry) {
        Provider.of<CountriesProvider>(context, listen: false)
            .moveCountry(sourceCountry, widget.country);
      },
      builder: (BuildContext context, candidateData, rejectedData) {
        return Column(
          children: <Widget>[
            AnimatedSize(
              duration: Duration(milliseconds: 100),
              vsync: this,
              child: candidateData.isEmpty
                  ? Container()
                  : Opacity(
                      opacity: 0.0,
                      child: tile,
                    ),
            ),
            Card(
              child: tile,
            )
          ],
        );
      },
    );

    return LayoutBuilder(builder: (context, boxConstrations) {
      return LongPressDraggable<Country>(
        data: widget.country,
        axis: Axis.vertical,
        maxSimultaneousDrags: 1,
        child: dragTarget,
        childWhenDragging: Container(),
        feedback: Material(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: boxConstrations.maxWidth),
            child: tile,
          ),
          elevation: 4.0,
        ),
      );
    });
  }
}
