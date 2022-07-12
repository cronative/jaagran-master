import 'dart:collection';
import 'dart:convert';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:jaagran/commons/strings.dart';
import 'package:jaagran/pages/common/appbar/common_appbar.dart';
import 'package:jaagran/pages/landing/model/seeking_model.dart';
import 'package:jaagran/pages/search/tabs/chat_tab.dart';
import 'package:jaagran/pages/search/tabs/sessions_tab.dart';
import 'package:jaagran/pages/search/tabs/users_tab.dart';
import 'package:jaagran/utils/size_config.dart';
import 'package:jaagran/utils/web_utils.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

import '../landing/seeking_tab.dart';
import 'model/search_autocomplete_model.dart';
import 'model/search_caht_model.dart';
import 'model/search_ls_model.dart';
import 'model/search_user_model.dart';

class SearchView extends StatefulWidget {
  @override
  _SearchViewState createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  SizeConfig _sf;
  TextEditingController _searchTextController = TextEditingController();
  bool isSearchCalled = false;
  bool isApiCall = false;
  TabController _controller_tab;
  Color accentColor;
  bool _autoFocus = true;
  Future<SeekingModel> _postBooks;
  Future<SeekingModel> _postVideo;
  Future<SeekingModel> _postAudio;
  Future<SeekingModel> _postEvents;
  Future<SeekingModel> _postSeeking;

  Future<SearchLsModel> _postLS;
  Future<SearchChatModel> _postChat;
  Future<SearchUserModel> _postUsers;

  GlobalKey<SeekingTabState> bookTabKey = GlobalKey<SeekingTabState>();
  GlobalKey<SeekingTabState> audioTabKey = GlobalKey<SeekingTabState>();
  GlobalKey<SeekingTabState> videoTabKey = GlobalKey<SeekingTabState>();
  GlobalKey<SeekingTabState> eventsTabKey = GlobalKey<SeekingTabState>();
  GlobalKey<SeekingTabState> seekTabKey = GlobalKey<SeekingTabState>();

  GlobalKey<SessionsTabState> sessionTabKey = GlobalKey<SessionsTabState>();
  GlobalKey<ChatTabState> chatTabKey = GlobalKey<ChatTabState>();
  GlobalKey<UsersTabState> usersTabKey = GlobalKey<UsersTabState>();

  int getTabLength() {
    int count = 0;
    if (bookCount > 0) {
      count++;
    }
    if (videoCount > 0) {
      count++;
    }
    if (audioCount > 0) {
      count++;
    }
    if (eventsCount > 0) {
      count++;
    }
    if (seekCount > 0) {
      count++;
    }
    if (sessionsCount > 0) {
      count++;
    }
    if (chatCount > 0) {
      count++;
    }
    if (usersCount > 0) {
      count++;
    }
    return count;
  }

  @override
  Widget build(BuildContext context) {
    _sf = SizeConfig.getInstance(context);

    accentColor = Theme.of(context).accentColor;
    bool isTabsAvailable = getTabLength() != 0;
    if (isTabsAvailable) {
      return DefaultTabController(
        length: getTabLength(),
        child: _scaffold(isTabsAvailable),
      );
    } else {
      return _scaffold(false);
    }
  }


  Widget _scaffold(bool isTabsAvailable) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      appBar: getCommonAppBar(context, _sf, isSearchView: true),
      body: ModalProgressHUD(
        inAsyncCall: isApiCall,
        child: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return <Widget>[
              SliverOverlapAbsorber(
                handle:
                    NestedScrollView.sliverOverlapAbsorberHandleFor(context),
                sliver: SliverAppBar(
                  backgroundColor: Colors.white,
                  floating: true,
                  elevation: isSearchCalled ? 5 : 0,
                  pinned: true,
                  primary: true,
                  forceElevated: true,
                  leading: Icon(
                    Icons.ac_unit,
                    size: 0,
                  ),
                  centerTitle: false,
                  expandedHeight: _sf.scaleSize(160),
                  flexibleSpace: FlexibleSpaceBar(
                    collapseMode: CollapseMode.pin,
                    background: PreferredSize(
                      preferredSize: Size.fromHeight(30),
                      child: _getAppBar(),
                    ),
                  ),
                  bottom: isTabsAvailable ? _tabBar() : null,
                ),
              ),
            ];
          },
          body: Visibility(
            visible: isSearchCalled,
            child: isTabsAvailable
                ? _tabs()
                : Container(
                    height: _sf.getScreenHeight() - _sf.scaleSize(180),
                    child: Center(
                      child: Text("No record found."),
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  _getAppBar() {
    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Container(
          alignment: AlignmentDirectional.center,
          color: Colors.white,
          padding:
              EdgeInsets.only(bottom: _sf.scaleSize(8), top: _sf.scaleSize(16)),
          child: Text(
            "Search",
            style: _sf.getLargeStyle(color: Theme.of(context).accentColor),
          ),
        ),
        Container(
          margin: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).hintColor,
            border: Border.all(color: Colors.white, width: 0.0),
            borderRadius: BorderRadius.all(Radius.circular(8.0)), //
          ),
          child: Row(
            // mainAxisSize: MainAxisSize.max,
            children: [
              Expanded(
                child: Container(
                  height: _sf.scaleSize(50),
                  child: Center(
                    child: TypeAheadField(
                      hideSuggestionsOnKeyboardHide: true,
                      hideOnError: true,
                      hideOnEmpty: true,
                      hideOnLoading: false,
                      loadingBuilder: (context) {
                        return Container(
                          height: 100,
                          padding: const EdgeInsets.all(8.0),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      },
                      noItemsFoundBuilder: (context) {
                        return Container();
                      },
                      textFieldConfiguration: TextFieldConfiguration(
                          autofocus: _autoFocus,
                          controller: _searchTextController,
                          style: _sf.getMediumStyle(),
                          decoration: InputDecoration(
                              hintText: "Search",
                              contentPadding: EdgeInsets.all(12),
                              hintStyle: _sf.getMediumStyle(
                                  color: Theme.of(context).accentColor),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(0),
                                  borderSide: BorderSide.none))),
                      suggestionsCallback: (pattern) async {
                        if (pattern.length < 3) return [];
                        return await _callSearchAutoComplete(pattern);
                      },
                      itemBuilder: (context, suggestion) {
                        return ListTile(
                          title: Text(suggestion['name']),
                        );
                      },
                      onSuggestionSelected: (suggestion) {
                        printToConsole("onSuggestionSelected");
                        // if (_searchTextController.text.trim().length > 3)
                        _autoFocus = false;
                        FocusScope.of(context).unfocus();
                        _searchTextController.text = suggestion['name'];
                        _callSearch();
                      },
                    ),
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  printToConsole("onTap");
                  if (_searchTextController.text.trim().length >= 3) {
                    _callSearch();
                    FocusScope.of(context).requestFocus(FocusNode());
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Icon(Icons.search),
                ),
              )
            ],
          ),
        ),
      ],
    );
  }

  _tabBar() {
    Color indicatorColor = Color(0x00ffC4AAEE);
    if (!isSearchCalled) {
      accentColor = Colors.white;
      indicatorColor = Colors.white;
    }
    return TabBar(
      isScrollable: true,
      indicatorWeight: 5,
      labelPadding: EdgeInsets.symmetric(horizontal: 12),
      indicatorSize: TabBarIndicatorSize.label,
      indicatorColor: indicatorColor,
      controller: _controller_tab,
      tabs: _getTabs(),
    );
  }

  _tabs() {
    String text = _searchTextController.text.trim();
    return TabBarView(
      controller: _controller_tab,
      dragStartBehavior: DragStartBehavior.start,
      physics: const AlwaysScrollableScrollPhysics(),
      children: _getTabDataList(text),
    );
  }

  List<Widget> _getTabs() {
    List<Widget> lst = [];
    if (bookCount > 0) {
      lst.add(Tab(
        child: Text(
          "eBooks(${_getCount(bookCount)})",
          style: _sf.getSmallStyle(color: accentColor),
        ),
      ));
    }
    if (videoCount > 0) {
      lst.add(Tab(
        child: Text(
          "Videos(${_getCount(videoCount)})",
          style: _sf.getSmallStyle(color: accentColor),
        ),
      ));
    }
    if (audioCount > 0) {
      lst.add(Tab(
        child: Text(
          "Audios(${_getCount(audioCount)})",
          style: _sf.getSmallStyle(color: accentColor),
        ),
      ));
    }
    if (eventsCount > 0) {
      lst.add(Tab(
        child: Text(
          "Events(${_getCount(eventsCount)})",
          style: _sf.getSmallStyle(color: accentColor),
        ),
      ));
    }
    if (seekCount > 0) {
      lst.add(Tab(
        child: Text(
          "Seek(${_getCount(seekCount)})",
          style: _sf.getSmallStyle(color: accentColor),
        ),
      ));
    }
    if (sessionsCount > 0) {
      lst.add(Tab(
        child: Text(
          "Sessions(${_getCount(sessionsCount)})",
          style: _sf.getSmallStyle(color: accentColor),
        ),
      ));
    }
    if (chatCount > 0) {
      lst.add(Tab(
        child: Text(
          "Chat(${_getCount(chatCount)})",
          style: _sf.getSmallStyle(color: accentColor),
        ),
      ));
    }
    if (usersCount > 0) {
      lst.add(Tab(
        child: Text(
          "Users(${_getCount(usersCount)})",
          style: _sf.getSmallStyle(color: accentColor),
        ),
      ));
    }

    return lst;
  }

  List<Widget> _getTabDataList(String text) {
    List<Widget> lst = [];
    // if (isApiCall) {
    //   return [
    //     Container(),
    //   ];
    // }

    if (bookCount > 0) {
      lst.add(Builder(
        builder: (BuildContext context) {
          return CustomScrollView(
            slivers: <Widget>[
              SliverOverlapInjector(
                  handle:
                      NestedScrollView.sliverOverlapAbsorberHandleFor(context)),
              SliverList(
                delegate: SliverChildBuilderDelegate((_, index) {
                  return SeekingTab(
                    key: bookTabKey,
                    type: "B",
                    postData: _postBooks,
                    searchText: text,
                  );
                }, childCount: 1),
              ),
            ],
          );
        },
      ));
    }
    if (videoCount > 0) {
      lst.add(Builder(
        builder: (BuildContext context) {
          return CustomScrollView(
            slivers: <Widget>[
              SliverOverlapInjector(
                  handle:
                      NestedScrollView.sliverOverlapAbsorberHandleFor(context)),
              SliverList(
                delegate: SliverChildBuilderDelegate((_, index) {
                  return SeekingTab(
                    key: videoTabKey,
                    type: "V",
                    postData: _postVideo,
                    searchText: text,
                  );
                }, childCount: 1),
              ),
            ],
          );
        },
      ));
    }
    if (audioCount > 0) {
      lst.add(Builder(
        builder: (BuildContext context) {
          return CustomScrollView(
            slivers: <Widget>[
              SliverOverlapInjector(
                  handle:
                      NestedScrollView.sliverOverlapAbsorberHandleFor(context)),
              SliverList(
                delegate: SliverChildBuilderDelegate((_, index) {
                  return SeekingTab(
                    key: audioTabKey,
                    type: "A",
                    postData: _postAudio,
                    searchText: text,
                  );
                }, childCount: 1),
              ),
            ],
          );
        },
      ));
    }
    if (eventsCount > 0) {
      lst.add(Builder(
        builder: (BuildContext context) {
          return CustomScrollView(
            slivers: <Widget>[
              SliverOverlapInjector(
                  handle:
                      NestedScrollView.sliverOverlapAbsorberHandleFor(context)),
              SliverList(
                delegate: SliverChildBuilderDelegate((_, index) {
                  return SeekingTab(
                    key: eventsTabKey,
                    type: "E",
                    postData: _postEvents,
                    searchText: text,
                  );
                }, childCount: 1),
              ),
            ],
          );
        },
      ));
    }
    if (seekCount > 0) {
      lst.add(Builder(
        builder: (BuildContext context) {
          return CustomScrollView(
            slivers: <Widget>[
              SliverOverlapInjector(
                  handle:
                      NestedScrollView.sliverOverlapAbsorberHandleFor(context)),
              SliverList(
                delegate: SliverChildBuilderDelegate((_, index) {
                  return SeekingTab(
                    key: seekTabKey,
                    type: "Q",
                    postData: _postSeeking,
                    searchText: text,
                  );
                }, childCount: 1),
              ),
            ],
          );
        },
      ));
    }
    if (sessionsCount > 0) {
      lst.add(Builder(
        builder: (BuildContext context) {
          return CustomScrollView(
            slivers: <Widget>[
              SliverOverlapInjector(
                  handle:
                      NestedScrollView.sliverOverlapAbsorberHandleFor(context)),
              SliverList(
                delegate: SliverChildBuilderDelegate((_, index) {
                  return SessionsTab(
                    key: sessionTabKey,
                    postData: _postLS,
                  );
                }, childCount: 1),
              ),
            ],
          );
        },
      ));
    }
    if (chatCount > 0) {
      lst.add(Builder(
        builder: (BuildContext context) {
          return CustomScrollView(
            slivers: <Widget>[
              SliverOverlapInjector(
                  handle:
                      NestedScrollView.sliverOverlapAbsorberHandleFor(context)),
              SliverList(
                delegate: SliverChildBuilderDelegate((_, index) {
                  return ChatTab(
                    key: chatTabKey,
                    postData: _postChat,
                  );
                }, childCount: 1),
              ),
            ],
          );
        },
      ));
    }
    if (usersCount > 0) {
      lst.add(Builder(
        builder: (BuildContext context) {
          return CustomScrollView(
            slivers: <Widget>[
              SliverOverlapInjector(
                  handle:
                      NestedScrollView.sliverOverlapAbsorberHandleFor(context)),
              SliverList(
                delegate: SliverChildBuilderDelegate((_, index) {
                  return UsersTab(
                    key: usersTabKey,
                    postData: _postUsers,
                  );
                }, childCount: 1),
              ),
            ],
          );
        },
      ));
    }

    return lst;
  }

  _callSearchAutoComplete(String pattern) async {
    HashMap params = HashMap();
    params['search'] = pattern;
    final result = await callPostAPI("autocomplete-search", params);
    final response = json.decode(result.toString());

    List<SearchAutoCompleteModel> listSuggestions =
        SearchAutoCompleteModel.getList(response['data']);
    List lst = [];
    listSuggestions.forEach((element) {
      lst.add({'name': element.name});
    });
    return lst;
  }

  int bookCount = -1;
  int videoCount = -1;
  int audioCount = -1;
  int eventsCount = -1;
  int seekCount = -1;
  int sessionsCount = -1;
  int chatCount = -1;
  int usersCount = -1;

  void _callSearch() async {
    printToConsole("call Search");
    setState(() {
      isApiCall = true;
    });
    if (isSearchCalled) {
      bookCount = -1;
      videoCount = -1;
      audioCount = -1;
      eventsCount = -1;
      seekCount = -1;
      sessionsCount = -1;
      chatCount = -1;
      usersCount = -1;
      if (bookTabKey.currentState != null) {
        printToConsole("bookTabKey");
        bookTabKey.currentState.lstSeekingData = null;
        bookTabKey.currentState.setState(() {});
      }
      if (videoTabKey.currentState != null) {
        printToConsole("videoTabKey");

        videoTabKey.currentState.lstSeekingData = null;
        videoTabKey.currentState.setState(() {});
      }
      if (audioTabKey.currentState != null) {
        printToConsole("audioTabKey");

        audioTabKey.currentState.lstSeekingData = null;
        audioTabKey.currentState.setState(() {});
      }
      if (eventsTabKey.currentState != null) {
        printToConsole("eventsTabKey");

        eventsTabKey.currentState.lstSeekingData = null;
        eventsTabKey.currentState.setState(() {});
      }
      if (seekTabKey.currentState != null) {
        printToConsole("seekTabKey");

        seekTabKey.currentState.lstSeekingData = null;
        seekTabKey.currentState.setState(() {});
      }

      if (sessionTabKey.currentState != null) {
        // sessionTabKey.currentState.lstSeekingData = null;
        sessionTabKey.currentState.setState(() {});
      }
    }
    setState(() {
      isSearchCalled = true;
    });

    String text = _searchTextController.text.trim();
    _postBooks = _callSeekingApi("B", text);
    _postVideo = _callSeekingApi("V", text);
    _postAudio = _callSeekingApi("A", text);
    _postEvents = _callSeekingApi("E", text);
    _postSeeking = _callSeekingApi("Q", text);
    _postLS = _callSearchLSApi("LS", text);
    _postChat = _callSearchChatApi("CHAT", text);
    _postUsers = _callSearchUserApi("USERS", text);
  }

  Future<SeekingModel> _callSeekingApi(String type, String text) async {
    HashMap params = HashMap();
    params["search"] = text;
    params["list_type"] = type;
    params["page[number]"] = "1";
    final result = await callPostAPI("search", params);
    final response = json.decode(result.toString());
    SeekingModel model = SeekingModel.fromJson(response);
    _setCount(type, model.data.total);
    return model;
  }

  Future<SearchLsModel> _callSearchLSApi(String type, String text) async {
    HashMap params = HashMap();
    params["search"] = text;
    params["list_type"] = type;
    params["page[number]"] = "1";
    final result = await callPostAPI("search", params);
    SearchLsModel sm = searchLsModelFromJson(result.toString());
    _setCount(type, sm.data.total);
    return sm;
  }

  Future<SearchChatModel> _callSearchChatApi(String type, String text) async {
    HashMap params = HashMap();
    params["search"] = text;
    params["list_type"] = type;
    params["page[number]"] = "1";
    final result = await callPostAPI("search", params);
    SearchChatModel sm = searchChatModelFromJson(result.toString());
    _setCount(type, sm.data.total);
    return sm;
  }

  Future<SearchUserModel> _callSearchUserApi(String type, String text) async {
    HashMap params = HashMap();
    params["search"] = text;
    params["list_type"] = type;
    params["page[number]"] = "1";
    final result = await callPostAPI("search", params);
    SearchUserModel sm = searchUserModelFromJson(result.toString());
    _setCount(type, sm.data.total);
    return sm;
  }

  void _setCount(String type, int total) {
    setState(() {
      switch (type) {
        case "A":
          audioCount = total;
          break;
        case "V":
          videoCount = total;
          break;
        case "B":
          bookCount = total;
          break;
        case "Q":
          seekCount = total;
          break;
        case "E":
          eventsCount = total;
          break;
        case "LS":
          sessionsCount = total;
          break;
        case "CHAT":
          chatCount = total;
          break;
        case "USERS":
          usersCount = total;
          break;
      }
      isApiCall = false;
    });
  }

  String _getCount(int count) {
    if (count == -1) return "";
    return '$count';
  }
}
