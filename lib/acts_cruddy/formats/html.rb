module ActsCruddy

  module Formats

    module Html

      def index
        @records = record_class.all
        instance_variable_set("@#{plural_record_name}", @records)
      end

      def create

        if @record.save

          url = case self.class.redirect_to_after_create.to_s
            when 'edit'
              url_for(:controller => controller_path, :action => :edit, :id => @record)
            when 'show'
              url_for(:controller => controller_path, :action => :show, :id => @record)
            when 'index'
              url_for(:controller => controller_path, :action => :index)
            else
              url_for(self.class.redirect_to_after_create)
          end

          redirect_to(url, :notice => hierarchical_translate('record_created', :name => record_name_value(@record)))

        else
          render :action => 'new'
        end
        
      end

      def update
        
        if @record.update_attributes(params[record_name])

          url = case self.class.redirect_to_after_update.to_s
            when 'edit'
              url_for(:controller => controller_path, :action => :edit, :id => @record)
            when 'show'
              url_for(:controller => controller_path, :action => :show, :id => @record)
            when 'index'
              url_for(:controller => controller_path, :action => :index)
            else
              url_for(self.class.redirect_to_after_update)
          end

          redirect_to(url, :notice => hierarchical_translate('record_updated', :name => record_name_value(@record)))

        else
          render :action => 'edit'
        end

      end

      def destroy
            
        @record.destroy

        redirect_to(
          url_for(:controller => controller_path, :action => :index),
          :notice => hierarchical_translate('record_destroyed', :name => record_name_value(@record)))

      end

      # The scope of a translation by default is based on the location of the
      # template file.  This provides a version of translate that will look
      # for a value based on the application_controller subclass name, then fall back to the
      # application_controller scope, regardless of where the template file is.
      def hierarchical_translate(key, options={})
       
        options = {
          :scope => controller_path.gsub('/', '.') + '.' + action_name,
          :default => t("application.#{action_name}.#{key}",
                          {
                            :human_name => record_class.model_name.human,
                            :plural_human_name => record_class.model_name.human.pluralize
                          }.merge(options))
        }.merge(options)

        t(key, options)

      end

    end

  end

end
