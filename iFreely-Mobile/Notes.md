29-3-2024
--------------------------------------
# Changed print to debugPrint
print just stopped working
--------------------------------------

28-3-2024
--------------------------------------
# Block BlocObserver
its a class that helps you see what heppens in bloc, 
its sets up a callback system for example when is created it calls the class 
and u can print the bloc created or smth
--------------------------------------

# Changed routing
- Use Routes."route-here"
- if you want to add a new route , add it in the const/routes folder , don't touch the main.dart
- you can pass parameters in routes now , example :

```dart

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(onPressed: (){
        Navigator.pushNamed(context, Routes.feedRoute, arguments: 'Data from home');
      },),
      body: Center(child: Text('Home')),
    );
  }
}
```

- dont forget to pass the data in the router

```dart
    case feedRoute:
    var data = settings.arguments as String;
    return MaterialPageRoute(builder: (_) => Feed(data));
```


# stop changing the main and background theme colors taki

# still working on messaging

# Use FlutterDownloader when you want to download files , there is an example in ChatRoom page , 


