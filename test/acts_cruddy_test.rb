$LOAD_PATH << File.expand_path( File.dirname(__FILE__) + '/../lib' )

require 'action_controller'
require 'test/unit'
require 'acts_cruddy'
require 'pp'

class ActsCruddyTest < Test::Unit::TestCase

  class DefaultController < ActionController::Base
    acts_cruddy
  end

  class AfterSaveController < ActionController::Base
    acts_cruddy :redirect_to_after_save => 'index'
  end

  class AfterCreateController < ActionController::Base
    acts_cruddy :redirect_to_after_save => 'index', :redirect_to_after_create => 'edit'
  end

  class AfterUpdateController < ActionController::Base
    acts_cruddy :redirect_to_after_update => 'index'
  end

  class JustHtmlController < ActionController::Base
    acts_cruddy :formats => [ :html ]
  end

  class OnlyIndexController < ActionController::Base
    acts_cruddy :only => :index
  end

  class ExceptDestroyController < ActionController::Base
    acts_cruddy :except => :destroy
  end

  class PreExistingUpdateController < ActionController::Base

    def update
      "Pre-existing"
    end

    acts_cruddy

  end

  def test_redirect_to_after
    assert_equal 'show', DefaultController.redirect_to_after_create
    assert_equal 'show', DefaultController.redirect_to_after_update
    assert_equal 'index', AfterSaveController.redirect_to_after_create
    assert_equal 'index', AfterSaveController.redirect_to_after_update
    assert_equal 'edit', AfterCreateController.redirect_to_after_create
    assert_equal 'index', AfterCreateController.redirect_to_after_update
    assert_equal 'show', AfterUpdateController.redirect_to_after_create
    assert_equal 'index', AfterUpdateController.redirect_to_after_update
  end

  def test_formats

    all_actions = [ 'create', 'update', 'destroy', 'show', 'index', 'new', 'edit' ]
    html_actions = [ 'create_html', 'update_html', 'destroy_html', 'index_html' ]
    json_actions = [ 'create_json', 'update_json', 'destroy_json', 'show_json', 'index_json', 'new_json' ]
    xml_actions = [ 'create_xml', 'update_xml', 'destroy_xml', 'show_xml', 'index_xml', 'new_xml' ]

    # all formats
   
    controller = DefaultController.new

    (all_actions + html_actions + json_actions + xml_actions).each do |action|
      assert controller.public_methods.include?(action.to_sym), "DefaultController is missing #{action} method."
    end

    # just HTML

    controller = JustHtmlController.new

    html_actions.each do |action|
      assert controller.public_methods.include?(action.to_sym), "JustHtmlController is missing #{action} method."
    end

    (json_actions + xml_actions).each do |action|
      assert !controller.public_methods.include?(action.to_sym), "JustHtmlController has #{action} method."
    end

  end

  def test_only
    controller = OnlyIndexController.new
    assert controller.public_methods.include?(:index), "OnlyIndexController is missing index method."
    [ :create, :update, :destroy, :show, :new, :edit ].each do |action|
      assert !controller.public_methods.include?(action), "OnlyIndexController has a #{action} method."
    end
  end

  def test_except
    controller = ExceptDestroyController.new
    assert !controller.public_methods.include?(:destroy), "ExceptDestroyController has the destroy method."
    [ :create, :update, :index, :show, :new, :edit ].each do |action|
      assert controller.public_methods.include?(action), "ExceptDestroyController is missing the #{action} method."
    end
  end

  def test_pre_exisiting_action
    # Make sure that if I had an action method before calling acts_cruddy that it is left unchanged
    controller = PreExistingUpdateController.new
    assert "Pre-existing", controller.update
  end

end
