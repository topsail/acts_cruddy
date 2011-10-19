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
  * *redirect_to_after_save* - the action to redirect to following a create or update (defaults to show)
  * *redirect_to_after_create* - the action to redirect to following a create (defaults to show)
  * *redirect_to_after_update* - the action to redirect to following an update (defaults to show)

### Example ###

    WidgetsController < AppllicationController

      acts_cruddy :formats => [:html, :json],
        :except => :destroy,
        :redirect_to_after_save => :index

    end

