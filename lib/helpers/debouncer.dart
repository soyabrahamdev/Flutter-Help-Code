// Versión 1.0.0
// Creditos
// https://stackoverflow.com/a/52922130/7834829
/*
  Usarlo en providers o services que neceiten espera para ejecutar alguna acción.
  Ejemplo, al usar un buscador:
	
	final debouncer = Debouncer( 
      duration: Duration( milliseconds: 500 )
    );
	
	...
	void getSuggetionsByQuery(String searchTerm){
      debouncer.value = '';
      debouncer.onValue = ( value ) async {
        
        final results = await searchMovie( value );
        _suggetionsStreamController.add( results );
  
      };
      Timer(Duration(milliseconds: 300), () {
        debouncer.value = searchTerm;
      });
    }
*/

import 'dart:async';

class Debouncer<T> {

  Debouncer({ 
    required this.duration, 
    this.onValue 
  });

  final Duration duration;

  void Function(T value)? onValue;

  T? _value;
  Timer? _timer;
  
  T get value => _value!;

  set value(T val) {
    _value = val;
    _timer?.cancel();
    _timer = Timer(duration, () => onValue!(_value!));
  }  
}
