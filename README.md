# Acts Cruddy #

Basic implementation of RESTful create, request, update and delete actions for Rails controllers.

## Usage ##

To add the default actions (index, show, new, create, edit, update, destroy) and formats (HTML, JSON and XML):

    WidgetsController < AppllicationController
      acts_cruddy
    end

### Options ###

  * *formats* - the supported formats (defaults to :html, :json, :xml)
  * *only* - only implement the specified actions
  * *except* - implement all but the specified actions

### Example ###

    WidgetsController < AppllicationController

      acts_cruddy :formats => [:html, :json],
        :except => :destroy,
        :redirect_to_after_save => :index

    end

### Customization ###
when using format :html, you can overwrite how the successful #create, #update or #destroy actions should be redirected
  * *redirect_after_save* - the code redirecting following a create or update (defaults to redirecting to :show)
  * *redirect_after_create* - the code redirecting following a create (defaults to redirect_after_save)
  * *redirect_after_update* - the code redirecting following an update (defaults to redirect_after_save)
  * *redirect_after_destroy* - the code redirecting following an update (defaults to redirecting to :index)