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

    end

  end

end
