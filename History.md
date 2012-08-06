0.0.8
=====

  * fix regression error from 0.0.7: allow again to assign any kind of object to options :redirect_to_after_..., not just strings or symbols 
  
0.0.7
=====

  * first attempt to make acts_cruddy inheritable, so that all acts_cruddy options get evaluated in the subclass context rather than the superclass context
  
0.0.6
=====

  * for HTML format, IE had problems when hitting RELOAD and the url didn't have an explicit format; fixed that
  
0.0.5
=====

  * for JSON format, return an empty string as json rather than nothing, so that client side parsers don't complain about parseerrors despite successful requests
  
0.0.4
=====

  * Added more helper methods for :record_name and :plural_record_name
  
0.0.3
=====


