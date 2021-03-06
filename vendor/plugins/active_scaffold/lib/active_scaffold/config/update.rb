module ActiveScaffold::Config
  class Update < Form
    self.crud_type = :update
    def initialize(*args)
      super
      self.nested_links = self.class.nested_links
    end

    # global level configuration
    # --------------------------
    # the ActionLink for this action
    def self.link
      @@link
    end
    def self.link=(val)
      @@link = val
    end
    @@link = ActiveScaffold::DataStructures::ActionLink.new('edit', :label => 'Edit', :type => :record, :security_method => :update_authorized?)

    # instance-level configuration
    # ----------------------------

    # the label= method already exists in the Form base class
    def label
      @label ? as_(@label) : as_('Update %s', @core.label.singularize)
    end

    attr_accessor :nested_links
    cattr_accessor :nested_links
    @@nested_links = false
    
    def show_action_link?
      true
    end
  end
end
