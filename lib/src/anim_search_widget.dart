import 'dart:math';
import 'package:anim_search_bar/src/consts.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AnimSearchBar extends StatefulWidget {
  ///  width - double ,isRequired : Yes
  ///  textController - TextEditingController  ,isRequired : Yes
  ///  onSuffixTap - Function, isRequired : Yes
  ///  rtl - Boolean, isRequired : No
  ///  autoFocus - Boolean, isRequired : No
  ///  style - TextStyle, isRequired : No
  ///  closeSearchOnSuffixTap - bool , isRequired : No
  ///  suffixIcon - Icon ,isRequired :  No
  ///  prefixIcon - Icon  ,isRequired : No
  ///  animationDurationInMilli -  int ,isRequired : No
  ///  helpText - String ,isRequired :  No
  ///  inputFormatters - TextInputFormatter, Required - No
  ///  boxShadow - bool ,isRequired : No
  ///  textFieldColor - Color ,isRequired : No
  ///  searchIconColor - Color ,isRequired : No
  ///  textFieldIconColor - Color ,isRequired : No
  ///  textInputAction  -TextInputAction, isRequired : No

  final double width;
  final double height;
  final TextEditingController textController;
  final Icon? suffixIcon;
  final Icon? prefixIcon;
  final Icon backIcon;
  final String? helpText;
  final int animationDurationInMilli;
  final VoidCallback? onSuffixTap;
  final bool rtl;
  final bool autoFocus;
  final TextStyle? style;
  final bool closeSearchOnSuffixTap;
  final Color? color;
  final Color? textFieldColor;
  final Color? searchIconColor;
  final Color? textFieldIconColor;
  final List<TextInputFormatter>? inputFormatters;
  final List<BoxShadow>? boxShadow;
  final TextInputAction textInputAction;
  final void Function(bool)? searchBarOpen;
  final void Function(String newVal)? onChanged;
  final bool clearOnSuffixTap;
  final bool clearOnClose;
  final bool closeOnSubmit;

  const AnimSearchBar({
    super.key,

    // The width cannot be null
    required this.width,
    this.searchBarOpen,
    // The textController cannot be null
    required this.textController,
    this.suffixIcon = suffixIconBlack,
    this.prefixIcon,
    this.helpText,
    this.backIcon = const Icon(Icons.arrow_back_ios_new_outlined),
    // Height of wrapper container
    this.height = 100,
    
    // choose your custom color
    this.color = Colors.white,

    // choose your custom color for the search when it is expanded
    this.textFieldColor = Colors.white,

    // choose your custom color for the search when it is expanded
    this.searchIconColor = Colors.black,

    // choose your custom color for the search when it is expanded
    this.textFieldIconColor = Colors.black,
    this.textInputAction = TextInputAction.done,

    // The onSuffixTap cannot be null
    this.onSuffixTap,
    this.animationDurationInMilli = 375,

  
    // make the search bar to open from right to left
    this.rtl = false,

    // make the keyboard to show automatically when the searchbar is expanded
    this.autoFocus = true,

    // TextStyle of the contents inside the searchbar
    this.style,

    // close the search on suffix tap
    this.closeSearchOnSuffixTap = false,

    // Textfield boxShadow
    this.boxShadow = boxShadowBlack,

    // can add list of inputformatters to control the input
    this.inputFormatters,

    this.onChanged,
    this.clearOnSuffixTap = false,
    this.clearOnClose = true,
    this.closeOnSubmit = true,
  });

  @override
  AnimSearchBarState createState() => AnimSearchBarState();
}



class AnimSearchBarState extends State<AnimSearchBar>
    with SingleTickerProviderStateMixin {

  bool isSearchbarOpen = false;

  //initializing the AnimationController
  late AnimationController _animationController;
  final FocusNode focusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    //Initializing the animationController which is responsible for the expanding and shrinking of the search bar
    _animationController = AnimationController(
      vsync: this,

      // animationDurationInMilli is optional, the default value is 375
      duration: Duration(milliseconds: widget.animationDurationInMilli),
    );
  }

  void unfocusKeyboard() {
    final FocusScopeNode currentScope = FocusScope.of(context);
    if (!currentScope.hasPrimaryFocus && currentScope.hasFocus) {
      FocusManager.instance.primaryFocus?.unfocus();
    }
  }

  void toogleSearchbar(){
    setState(() {
      isSearchbarOpen = !isSearchbarOpen;
    });
  }

  void closeOnSubmit(){
    if(widget.closeOnSubmit) {
      unfocusKeyboard();
      toogleSearchbar();                    
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,

      //if the rtl is true, search bar will be from right to left
      alignment: widget.rtl ? Alignment.centerRight : Alignment.centerLeft,

      //Using Animated container to expand and shrink the widget
      child: AnimatedContainer(
        duration: Duration(milliseconds: widget.animationDurationInMilli),
        height: widget.height,
        width: isSearchbarOpen ? widget.width : 48,
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          // can add custom  color or the color will be white
          color: isSearchbarOpen ? widget.textFieldColor : widget.color,
          borderRadius: BorderRadius.circular(30.0),

          // show boxShadow unless false was passed
          boxShadow: widget.boxShadow
        ),
        child: Stack(
          children: [
            //Using Animated Positioned widget to expand and shrink the widget
            AnimatedPositioned(
              duration: Duration(milliseconds: widget.animationDurationInMilli),
              top: 6.0,
              right: 7.0,
              curve: Curves.easeOut,
              child: AnimatedOpacity(
                opacity: isSearchbarOpen ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 200),
                child: Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: widget.color,
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  child: AnimatedBuilder(
                    builder: (context, widget) {
                      //Using Transform.rotate to rotate the suffix icon when it gets expanded
                      return Transform.rotate(
                        angle: _animationController.value * 2.0 * pi,
                        child: widget,
                      );
                    },
                    animation: _animationController,
                    child: GestureDetector(
                      onTap: () {
                        //trying to execute the onSuffixTap function
                        if(widget.onSuffixTap != null) widget.onSuffixTap!();
                        // * if field empty then the user trying to close bar
                        if (widget.textController.text == '') {
                          unfocusKeyboard();
                          toogleSearchbar();
                          if(widget.searchBarOpen != null)widget.searchBarOpen!(isSearchbarOpen);
                          ///reverse == close
                          _animationController.reverse();
                        }
                        // // * why not clear textfield here?
                        if (widget.clearOnSuffixTap) {
                        widget.textController.clear();
                        widget.onChanged?.call("");
                      }
                        ///closeSearchOnSuffixTap will execute if it's true
                        if (widget.closeSearchOnSuffixTap) {
                          unfocusKeyboard();
                          toogleSearchbar();
                        }
                      },
                      child: widget.suffixIcon,
                    ),
                  ),
                ),
              ),
            ),
            AnimatedPositioned(
              duration: Duration(milliseconds: widget.animationDurationInMilli),
              left: isSearchbarOpen ? 40.0 : 20.0,
              curve: Curves.easeOut,
              top: 11.0,

              //Using Animated opacity to change the opacity of th textField while expanding
              child: AnimatedOpacity(
                opacity: isSearchbarOpen ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 200),
                child: Container(
                  padding: const EdgeInsets.only(left: 10),
                  alignment: Alignment.topCenter,
                  width: widget.width / 1.7,
                  child: TextField(
                    //Text Controller. you can manipulate the text inside this textField by calling this controller.
                    controller: widget.textController,
                    inputFormatters: widget.inputFormatters,
                    focusNode: focusNode,
                    textInputAction: widget.textInputAction,
                    cursorRadius: const Radius.circular(10.0),
                    cursorWidth: 2.0,
                    onChanged: (value) {
                      widget.onChanged?.call(value);
                    },
                    onSubmitted: (value) {
                      closeOnSubmit();
                    },
                    onEditingComplete: closeOnSubmit,

                    style: widget.style ?? const TextStyle(color: Colors.black),
                    cursorColor: Colors.black,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.only(bottom: 5),
                      isDense: true,
                      floatingLabelBehavior: FloatingLabelBehavior.never,
                      labelText: widget.helpText,
                      labelStyle: const TextStyle(
                        color: Color(0xff5B5B5B),
                        fontSize: 17.0,
                        fontWeight: FontWeight.w500,
                      ),
                      alignLabelWithHint: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            ///Using material widget here to get the ripple effect on the prefix icon
            Material(
              /// can add custom color or the color will be white
              /// toggle button color based on toggle state
              color: isSearchbarOpen ?  widget.textFieldColor : widget.color ,
              borderRadius: BorderRadius.circular(30.0),
              child: IconButton(
                splashRadius: 19.0,

                ///prefixIcon is of type Icon
                icon: widget.prefixIcon != null
                    ? isSearchbarOpen
                      ? widget.backIcon
                      : widget.prefixIcon!
                    : Icon(
                        isSearchbarOpen ? Icons.arrow_back_ios : Icons.search,
                        // search icon color when closed
                        color: isSearchbarOpen
                          ? widget.textFieldIconColor
                          : widget.searchIconColor,
                        size: 20.0,
                      ),
                onPressed: () {
                  setState(
                    () {
                      ///if the search bar is closed
                      if (!isSearchbarOpen) {
                        isSearchbarOpen = true;
                        if (widget.autoFocus) FocusScope.of(context).requestFocus(focusNode);

                        ///forward == expand
                        _animationController.forward();
                      } else {
                        ///if the search bar is expanded
                        isSearchbarOpen = false;

                        ///if the autoFocus is true, the keyboard will close, automatically
                        if (widget.autoFocus) unfocusKeyboard();

                        ///reverse == close
                        _animationController.reverse();
                      }
                    },
                  );
                  if (!isSearchbarOpen  &&  widget.clearOnClose) widget.textController.clear();
                  if(widget.searchBarOpen != null) widget.searchBarOpen!(isSearchbarOpen);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

