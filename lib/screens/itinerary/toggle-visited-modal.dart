import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

class ToggleVisitedModal extends StatefulWidget {
  ToggleVisitedModal({
    Key key,
    this.color,
  }) : super(key: key);

  final Color color;

  @override
  _ToggleVisitedModalState createState() => new _ToggleVisitedModalState();
}

class _ToggleVisitedModalState extends State<ToggleVisitedModal> {
  String dropdownValue = 'hour';
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController textController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    textController.dispose();

    super.dispose();
  }

  _getContent(BuildContext buildContext) {
    Color color = widget.color;
    final fields = <Widget>[
      Padding(
          padding: EdgeInsets.symmetric(vertical: 40),
          child: AutoSizeText('Time spent here',
              style: TextStyle(fontSize: 23, fontWeight: FontWeight.w300))),
      Container(
          margin: EdgeInsets.only(bottom: 20),
          child: TextFormField(
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(vertical: 20.0),
              prefixIcon: Padding(
                  padding: EdgeInsets.only(left: 20.0, right: 5.0),
                  child: Icon(
                    Icons.label,
                    size: 15,
                  )),
              filled: true,
              errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(5.0)),
                  borderSide: BorderSide(width: 1.0, color: Colors.red)),
              focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(5.0)),
                  borderSide: BorderSide(width: 1.0, color: Colors.red)),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(5.0)),
                  borderSide:
                      BorderSide(width: 0.0, color: Colors.transparent)),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(5.0)),
                  borderSide:
                      BorderSide(width: 0.0, color: Colors.transparent)),
              hintText: 'How long were you here?',
              hintStyle: TextStyle(fontSize: 13),
            ),
            controller: textController,
            validator: (value) {
              if (value.isEmpty) {
                return 'Please estimate how much time you spent here';
              }
              return null;
            },
          )),
      GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            print(FocusScope.of(buildContext));
            print('hi');
            FocusScope.of(buildContext).unfocus();
          },
          child: DropdownButtonFormField(
              decoration: InputDecoration(
                filled: true,
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(5.0)),
                    borderSide:
                        BorderSide(width: 0.0, color: Colors.transparent)),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(5.0)),
                    borderSide:
                        BorderSide(width: 0.0, color: Colors.transparent)),
                contentPadding:
                    EdgeInsets.only(top: 5.0, bottom: 5, right: 10, left: 20),
              ),
              value: dropdownValue,
              icon: Icon(Icons.keyboard_arrow_down),
              iconSize: 15,
              elevation: 16,
              style: TextStyle(fontSize: 13, color: Colors.black87),
              isExpanded: true,
              items: <dynamic>[
                {"display": 'Hours', "value": "hour"},
                {"display": 'Minutes', "value": "minute"}
              ].map((dynamic value) {
                return DropdownMenuItem<String>(
                  value: value['value'],
                  child: Text(value['display']),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  dropdownValue = value;
                });
              })),
      Container(
          width: double.infinity,
          margin: EdgeInsets.only(top: 40, left: 20, right: 20, bottom: 20),
          child: FlatButton(
            color: color.withOpacity(0.8),
            shape: RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(5.0)),
            child: Padding(
                padding: EdgeInsets.symmetric(vertical: 15),
                child: AutoSizeText('Save as visited',
                    style: TextStyle(
                        fontSize: 23,
                        fontWeight: FontWeight.w300,
                        color: Colors.white))),
            onPressed: () async {
              if (_formKey.currentState.validate()) {
                Navigator.pop(buildContext,
                    {"value": textController.text, "unit": dropdownValue});
              }
            },
          )),
      Container(
          width: double.infinity,
          margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          child: FlatButton(
            child: Padding(
                padding: EdgeInsets.symmetric(vertical: 15),
                child: AutoSizeText('Close',
                    style:
                        TextStyle(fontSize: 23, fontWeight: FontWeight.w300))),
            onPressed: () {
              Navigator.pop(buildContext);
            },
          ))
    ];
    return Dialog(
        child: Form(
            key: _formKey,
            child: Container(
                padding: EdgeInsets.only(left: 20.0, right: 20, bottom: 20),
                child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: fields.length,
                    itemBuilder: (BuildContext listContext, int index) {
                      return fields[index];
                    }))));
  }

  @override
  Widget build(BuildContext context) {
    return _getContent(context);
  }
}

// class DropdownFormField extends FormField<String> {

//   DropdownFormField({
//     FormFieldSetter<String> onSaved,
//     FormFieldValidator<String> validator,
//     String initialValue = '',
//     bool autovalidate = false
//   }) : super(
//     onSaved: onSaved,
//     validator: validator,
//     initialValue: initialValue,
//     autovalidate: autovalidate,
//     builder: (FormFieldState<String> state) {
//       return InputDecorator(
//                   decoration: InputDecoration(
//                     filled: true,
//                     focusedBorder: OutlineInputBorder(
//                         borderRadius: BorderRadius.all(Radius.circular(5.0)),
//                         borderSide:
//                             BorderSide(width: 0.0, color: Colors.transparent)),
//                     enabledBorder: OutlineInputBorder(
//                         borderRadius: BorderRadius.all(Radius.circular(5.0)),
//                         borderSide:
//                             BorderSide(width: 0.0, color: Colors.transparent)),
//                     contentPadding: EdgeInsets.only(
//                         top: 5.0, bottom: 5, right: 10, left: 20),
//                   ),
//                   child: DropdownButton<String>(
//                       isExpanded: true,
//                       value: state.value,
//                       icon: Icon(Icons.keyboard_arrow_down),
//                       iconSize: 15,
//                       elevation: 16,
//                       style: TextStyle(fontSize: 13, color: Colors.black87),
//                       underline: Container(),
//                       onChanged: (String newValue) {
//                         print(newValue);
//                         // setState(() {
//                         //   dropdownValue = newValue;
//                         // });
//                         state.didChange(newValue);
//                       },
//                       items: <dynamic>[
//                         {"display": 'Hours', "value": "hour"},
//                         {"display": 'Minutes', "value": "minute"}
//                       ].map((dynamic value) {
//                         return DropdownMenuItem<String>(
//                           value: value['value'],
//                           child: Text(value['display']),
//                         );
//                       }).toList()))    }
//   );
// }
