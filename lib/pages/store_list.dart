import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_todo/models/store.dart';
import 'package:flutter_todo/pages/add_store.dart';
import 'package:flutter_todo/pages/store_detail.dart';
import 'package:flutter_todo/pages/tasks_page.dart';
import 'package:flutter_todo/view_models/add_store_view_model.dart';
import 'package:flutter_todo/view_models/login_view_model.dart';
import 'package:flutter_todo/view_models/store_detail_view_model.dart';
import 'package:flutter_todo/view_models/store_list_view_model.dart';
import 'package:provider/provider.dart';
import 'login_screen.dart';

class StoresList extends StatefulWidget {
  const StoresList({ Key? key }) : super(key: key);

  @override
  _StoresListState createState() => _StoresListState();
}



class _StoresListState extends State<StoresList> {
  
  late StoreListViewModel _storeListViewModel;

  @override
  void initState() {
    super.initState();

    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user == null) {
        Navigator.pushAndRemoveUntil(context,
            MaterialPageRoute(builder: (context) {
          return ChangeNotifierProvider(
            create: (context) => LoginViewModel(),
            child: LoginScreen(),
          );
        }), (route) => false);
      }
    });
  }

  void _navigateToAddStore(BuildContext context) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) {
              return ChangeNotifierProvider(
                  create: (_) => AddStoreViewModel(), child: AddStorePage());
            },
            fullscreenDialog: true));
  }

  void _navigateToStoreDetail(BuildContext context, Store store) async {
    final bool refreshState =
        await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return ChangeNotifierProvider(
          create: (_) => StoreDetailViewModel(store), child: StoreDetailPage());
    }));

    if (refreshState) {
      _storeListViewModel.refreshTheScreen();
    }
  }

  void _deleteStore(BuildContext context, Store store) async {
    final isDeleted = await _storeListViewModel.deleteStore(store);
    if (isDeleted) {
      showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            title: Text("Success!"),
            content: Text("Store has been successfully deleted."),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text("OK"),
              ),
            ],
          );
        },
        barrierDismissible: false,
      );
    }
  }

  Widget _buildList(QuerySnapshot snapshot) {
    final stores = _storeListViewModel.getStores(snapshot);

    return ListView.builder(
      itemCount: stores.length,
      itemBuilder: (context, index) {
        final store = stores[index];
        return Dismissible(
            key: Key(store.id),
            direction: DismissDirection.endToStart,
            onDismissed: (direction) {
              print(store.id);
              _deleteStore(context, store);
            },
            confirmDismiss: (DismissDirection direction) async {
              return await showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text("Confirm"),
                    content: const Text(
                        "Are you sure you wish to delete this item?"),
                    actions: <Widget>[
                      TextButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          child: const Text("DELETE")),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text("CANCEL"),
                      ),
                    ],
                  );
                },
              );
            },
            background: Container(
              color: Colors.redAccent,
              child: Row(
                children: [
                  Expanded(child: Container()),
                  Icon(
                    Icons.delete,
                    color: Colors.white,
                  ),
                  SizedBox(width: 20)
                ],
              ),
            ),
            child: ListTile(
              leading: store.imageUrl == null
                  ? null
                  : Hero(
                      tag: store.id,
                      child: ClipRect(
                        child: ClipRRect(
                          child: Container(
                              color: Colors.grey[500],
                              child: Image.network(
                                store.imageUrl!,
                                height: 50,
                                width: 50,
                                fit: BoxFit.cover,
                              )),
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                    ),
              title: Text(store.name),
              subtitle: Text(store.address),
              trailing: FutureBuilder<int>(
                future: store.itemsCount,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return CircleAvatar(
                      child: Text(
                        snapshot.data!.toString(),
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.bold),
                      ),
                      backgroundColor: Colors.blue,
                    );
                  } else {
                    return SizedBox.shrink();
                  }
                },
              ),
              onTap: () {
                print("Store Tapped");
                _navigateToStoreDetail(context, store);
              },
            ));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    _storeListViewModel = Provider.of<StoreListViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: Row(mainAxisAlignment: MainAxisAlignment.center,children: [ Icon(Icons.storefront), SizedBox(width: 8,) ,Text('Stores', textAlign: TextAlign.center,)]),
        centerTitle: true,
        leading: IconButton(onPressed: () {
          FirebaseAuth.instance.signOut();
        }, icon: Icon(Icons.logout)),
        actions: [
          TextButton(
              onPressed: () => _navigateToAddStore(context),
              child: Icon(
                Icons.add,
                color: Colors.white,
              ))
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _storeListViewModel.storeAsStream,
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
            return _buildList(snapshot.data!);
          } else {
            return Center(
              child: Text("No Stores Added"),
            );
          }
        },
      ),


    );
  }
}
