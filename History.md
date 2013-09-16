0.1.2
=====
  * set http status 422 if update fails with format :html

0.1.1
=====
  * let controllers implement a method #permitted_params, which clears request parameters for record updates
    (this allows acts_cruddy to work with strong_parameters)
  * FIX BUG: don't call #set_record_variables for all controller actions anymore, just for the few where it matters!

0.1.0
=====

  * retire options *redirect_to_after-xxx* in favor of overwriting the *redirect_after_xxx* methods
  * allow specifying how to redirect after #destroy

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


