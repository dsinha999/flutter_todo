import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_todo/models/item.dart';
import 'package:flutter_todo/view_models/store_detail_view_model.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:provider/provider.dart';

class StoreDetailPage extends StatefulWidget {
  const StoreDetailPage({Key? key}) : super(key: key);

  @override
  _StoreDetailPageState createState() => _StoreDetailPageState();
}

class _StoreDetailPageState extends State<StoreDetailPage> {
  late StoreDetailViewModel _storeDetailViewModel;

  final _formKey = GlobalKey<FormState>();
  TextEditingController _itemNameController = TextEditingController();
  TextEditingController _itemQuantityController = TextEditingController();
  TextEditingController _itemPriceController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    _storeDetailViewModel = Provider.of<StoreDetailViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_storeDetailViewModel.store.name),
        leading: IconButton(onPressed: () {
          Navigator.pop(context, true);
        }, icon: Icon(Icons.arrow_back)),
      ),
      body: SafeArea(
          child: LoaderOverlay(
        child: ListView(
          children: [
            (_storeDetailViewModel.store.imageUrl == null)
                ? Container(
                    height: 0,
                  )
                : Hero(
                    tag: _storeDetailViewModel.store.id,
                    child: Image.network(
                      _storeDetailViewModel.store.imageUrl!,
                      fit: BoxFit.cover,
                      height: 200,
                    ),
                  ),

            _buildForm(context), // Form Fields

            Container(
              margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              height: 50,
              width: MediaQuery.of(context).size.width,
              child: ElevatedButton(
                  onPressed: () => _saveButtonTapped(context),
                  child: Text(
                    'ADD',
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  )),
            ),

            _buildList(context),
          ],
        ),
      )),
    );
  }

  Widget _buildList(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _storeDetailViewModel.itemAsStream,
      builder: (context, snapShot) {
        if (snapShot.hasData && snapShot.data!.docs.isNotEmpty) {
          final items = _storeDetailViewModel.getItems(snapShot.data!);

          return ListView.builder(
            shrinkWrap: true,
            itemCount: items.length,
            itemBuilder: (context, index) {
              return _listTile(context, items[index], index);
            },
          );
        } else {
          return Container(
            height: 300,
            child: Center(child: Text("No Items Added")),
          );
        }
      },
    );
  }

  Widget _listTile(BuildContext context, Item item, int index) {
    return ListTile(
      title: Text(item.name,
          style: TextStyle(fontWeight: FontWeight.normal, fontSize: 18)),
      subtitle: Text("Price: ${item.price}"),
      minLeadingWidth: 10,
      leading: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text(
          (index + 1).toString() + ".",
          style: TextStyle(fontSize: 21),
        ),
      ]),
      trailing: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text("Quantity",
            style: TextStyle(fontWeight: FontWeight.normal, fontSize: 13)),
        Text(
          item.quantity,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 21),
        )
      ]),
    );
  }

  Widget _buildForm(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Form(
          key: _formKey,
          child: Column(children: [
            TextFormField(
              controller: _itemNameController,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: "Item Name",
                hintText: "e.g. Tooth Brush",
              ),
              onChanged: (value) {
                _storeDetailViewModel.item.name = value;
              },
              validator: (val) {
                if (val == null) {
                  return 'Please enter name';
                } else if (val.length == 0) {
                  return 'Please enter name';
                } else if (val.length < 2) {
                  return 'Name should be greater than 2 charcters.';
                } else {
                  return null;
                }
              },
            ),
            TextFormField(
              controller: _itemQuantityController,
              textInputAction: TextInputAction.next,
              keyboardType:
                  TextInputType.numberWithOptions(signed: true, decimal: false),
              inputFormatters: [
                LengthLimitingTextInputFormatter(10),
                FilteringTextInputFormatter.digitsOnly
              ],
              decoration: InputDecoration(
                labelText: "Item Quantity",
                hintText: "e.g. 2",
              ),
              onChanged: (value) {
                _storeDetailViewModel.item.quantity = value;
              },
              validator: (val) {
                if (val == null) {
                  return 'Please enter quantity';
                } else if (val.length == 0) {
                  return 'Please enter quantity';
                } else {
                  return null;
                }
              },
            ),
            TextFormField(
              controller: _itemPriceController,
              textInputAction: TextInputAction.done,
              keyboardType:
                  TextInputType.numberWithOptions(signed: true, decimal: true),
              inputFormatters: [
                LengthLimitingTextInputFormatter(10),
                FilteringTextInputFormatter.allow(RegExp("[0-9.]"))
              ],
              decoration: InputDecoration(
                labelText: "Item Price",
                hintText: "e.g. 10",
              ),
              onChanged: (value) {
                _storeDetailViewModel.item.price = value;
              },
              validator: (val) {
                if (val == null) {
                  return 'Please enter price';
                } else if (val.length == 0) {
                  return 'Please enter price';
                } else {
                  return null;
                }
              },
            ),
          ])),
    );
  }

  void _saveButtonTapped(BuildContext context) async {
    FocusScope.of(context).unfocus();

    if (_formKey.currentState!.validate()) {
      context.loaderOverlay.show();
      final isSaved = await _storeDetailViewModel.saveItem();
      context.loaderOverlay.hide();
      if (isSaved) {
        // Navigator.pop(context);
        _itemNameController.text = "";
        _itemQuantityController.text = "";
        _itemPriceController.text = "";
      } else {
        showDialogPopup(context, _storeDetailViewModel.message);
      }
    } else {
      print('Addddd');
    }
  }

  void showDialogPopup(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(""),
          content: Text(message),
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
