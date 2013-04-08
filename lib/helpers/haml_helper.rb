module CloudManage
  module HamlHelper

    def show_model(model)
      haml_tag :dl do
        model.values.each do |attr, value|
          haml_tag :dt do
            haml_concat attr.to_s.gsub('_', ' ').titlecase
          end
          haml_tag :dd do
            haml_concat case value
              when String then value
              when TrueClass then 'yes'
              when FalseClass then 'no'
              when NilClass then '<em class="muted">information not available</em>'
              else
                value.to_s
            end
          end
        end
      end
    end

    def pagination(model, url, opts={})
      haml_tag :div, :class => (opts[:klass]||[]).push(:pagination) do
        haml_tag :ul do
          haml_tag :li do
            haml_tag :a, :href => url("#{url}?page=#{model.prev_page}") do
              haml_concat 'Prev'
            end if model.prev_page
            haml_tag :a, :href => url("#{url}?page=#{model.next_page}") do
              haml_concat 'Next'
            end if model.next_page
          end
        end
      end
    end

    def form_for(model, action_url, &block)
      @model = model
      @model_name = @model.class.table_name.to_s.singularize
      haml_tag :form, :class => 'form-horizontal', :method => :post, :action => action_url do
        haml_tag :fieldset do
          unless model.new?
            haml_tag :input, :type => :hidden, :name => "#{@model_name}[id]", :value => model.id
          end
          block.call if block_given?
          haml_tag :div, :class => 'control-group' do
            haml_tag :div, :class => 'controls' do
              haml_tag :button, :type => :submit do
                submit_label = model.new? ? 'Create' : 'Save'
                haml_concat submit_label
              end
            end
          end
        end
      end
    end

    def control_header(label)
      haml_tag :legend do
        haml_concat label
      end
    end

    def control_group(attr_name, label='', opts={}, &block)
      haml_tag :div, :class => 'control-group' do
        @label = label.empty? ? attr_name.to_s.capitalize : label
        haml_tag :label, :class => 'control-label', :for => "input#{attr_name.to_s.capitalize}" do
          haml_concat @label
        end unless opts[:no_label]
        haml_tag :div, :class => 'controls' do
          block.call if block_given?
        end
      end
    end

    def input(type, attr_name)
      haml_tag :input,
        :type => type,
        :name => "#{@model_name}[#{attr_name}]",
        :id => "input#{attr_name.to_s.capitalize}",
        :value => @model.respond_to?(attr_name) ? @model.send(attr_name) : ''
    end

    def text(attr_name)
      haml_tag :textarea, :name => "#{@model_name}[#{attr_name}]" do
        haml_concat @model.send(attr_name)
      end
    end

    def select(attr_name, options=[])
      if !@model.new? and @model.respond_to?(attr_name)
        selected = @model.send(attr_name).to_s
      else
        selected = false
      end
      haml_tag :select, :name => "#{@model_name}[#{attr_name}]" do
        haml_tag :option, :value => '' do
          haml_concat ''
        end
        options.each do |v|
          value, label = v.to_a.first
          if selected and selected == value.to_s
            haml_tag :option, :value => value, :selected => :selected do
              haml_concat label
            end
          else
            haml_tag :option, :value => value do
              haml_concat label
            end
          end
        end
      end
    end

    def checkbox(attr_name)
      haml_tag :label, :class => :checkbox do
        is_active = @model.respond_to?("#{attr_name}?") ? @model.send("#{attr_name}?") : false
        if is_active
          haml_tag :input, :type => :checkbox, :name => "#{@model_name}[#{attr_name}]", :checked => :checked
        else
          haml_tag :input, :type => :checkbox, :name => "#{@model_name}[#{attr_name}]"
        end
        haml_concat @label
      end
    end

    def time_ago(time)
      time = DateTime.parse(time.to_s).xmlschema
      haml_tag :abbr, :class => :ago, :title => time do
        haml_concat time
      end
    end

  end
end
