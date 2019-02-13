import 'package:flutter/material.dart';
import 'polls_model.dart';
import 'slider_element.dart';
import 'radio_element.dart';
import 'checkbox_element.dart';
import 'switch_element.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class PollElement extends StatefulWidget {
  final Poll poll;

  PollElement({Key key, @required this.poll});


  @override
  State<StatefulWidget> createState() {
    return PollElementsState();
  }

}

class PollElementsState extends State<PollElement> {
  Map<String, Map<String, dynamic>> formState = {};


  callback(Map<dynamic, dynamic> newState){

    if (newState.keys.contains('checkbox') && formState.keys.contains('checkbox')){
      Map <String, dynamic> checkboxState = newState['checkbox'];
      formState['checkbox'].addAll(checkboxState);
    }
    else if (newState.keys.contains('checkbox') && !formState.keys.contains('checkbox')){
      formState.addAll(newState);
    }
    else if (newState.containsKey('radio') && formState.keys.contains('radio')) {
      Map <String, dynamic> radioState = newState['radio'];
      formState['radio'].addAll(radioState);
    }
    else if (newState.containsKey('radio') && !formState.keys.contains('radio')) {
      Map <String, dynamic> radioState = newState['radio'];
      formState['radio'] = radioState;
    }
    else if (newState.containsKey('switch') && formState.keys.contains('switch')) {
      Map <String, dynamic> radioState = newState['switch'];
      formState['switch'].addAll(radioState);
    }
    else if (newState.containsKey('switch') && !formState.keys.contains('switch')) {
      Map <String, dynamic> radioState = newState['switch'];
      formState['switch'] = radioState;
    }
    else if (newState.containsKey('slider') && formState.keys.contains('slider')) {
      Map <String, dynamic> sliderState = newState['slider'];
      formState['slider'].addAll(sliderState);
    }
    else if (newState.containsKey('slider') && !formState.keys.contains('slider')) {
      formState.addAll(newState);
    }
    else if (formState.length == 0){
      formState = newState;
    }
  }

  @override
  Widget build(BuildContext context) {
    String title = widget.poll.title;

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: buildPoll(),
    );
  }

  buildPoll(){

//
    return Column(
      children: <Widget>[
        buildElements(),
        submitButton(),
      ],
    );
  }

  buildElements(){
    final List elements = List();
    Map <dynamic, dynamic> allElements = widget.poll.elements;
    allElements.forEach((key, value) => elements.add(value));
    print('All elems' + allElements.toString());
    print('FormState : $formState');

    return Expanded(
      child: ListView.builder(
          itemCount: allElements.length,
          itemBuilder: (context, index) {
            final elem = ElementSlider.fromElement(index, elements[index]);
            final elemtype = elements[index]['type'];
//            print ('Elemtype: ${elemtype}');

            if (elemtype == 'slider') {

              return SliderElement(element: elements[index], callback: callback, formState: formState,);
            }
            else if(elemtype == 'checkbox') {
              return CheckboxElement(element: elements[index], callback: callback, formState: formState,);
            }
            else if (elemtype == 'radio') {
              return RadioElement(element: elements[index], callback: callback, formState: formState,);
            }
            else if (elemtype == 'switch') {
              return SwitchElement(element: elements[index], callback: callback, formState: formState,);
            }
            else if (elem == null) {
              print('Elem Null!');
              return ListTile(
                title: Text('ELEM type = null!'),
              );
            }
          }
      ),
    );

  }

  submitButton(){
    //TODO: Add validation
    String button = widget.poll.button;
    return Container(
      padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 200.0),
      child: RaisedButton(
        onPressed: () => Firestore.instance.collection('results')
            .document().setData(
            {
              'created_at': FieldValue.serverTimestamp(),
              'pollID': widget.poll.polls.documentID,
              'elements' : formState,
            }),
        child: Text(button),
      ),
    );
  }
}