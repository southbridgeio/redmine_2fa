module RedminePluginloader
  module Patches
    module DeferPluginDependencyCheckPatch
      module Plugin
        module ClassMethods
          def self.prepended(base)
            base.class_eval do
              cattr_accessor :pluginloader_requirements
              cattr_accessor :pluginloader_is_startup
              base.pluginloader_requirements ||= []
              base.pluginloader_is_startup = true
            end
          end

          def check_pluginloader_requirements
            pluginloader_requirements.each do |id, dep, arg|
              plugin = find(id)
              begin
                plugin.requires_redmine_plugin(dep, arg, false)
              rescue ::Redmine::PluginNotFound => e
                raise ::Redmine::PluginRequirementError,
                      "#{id} plugin requires the #{dep} plugin, which is not installed.",
                      $ERROR_INFO.backtrace
              end
            end
          end

          # HACK: Inject our dependency check and make sure to only run the real
          #       'mirror_assets' code when 'mirror_plugins_assets_on_startup'
          #       really is enabled, or when called after the plugin loading phase.
          def mirror_assets
            if pluginloader_is_startup
              self.pluginloader_is_startup = false
              check_pluginloader_requirements
            end
            if Redmine::Configuration['mirror_plugins_assets_on_startup'] != false
              super
            end
          end

          # Make sure id is always treated as symbol to ease handling of plugin names.

          def register(id, &block)
            super(id.to_sym, &block)
          end

          def find(id)
            super(id.to_sym)
          end

          def unregister(id)
            super(id.to_sym)
          end

          def installed?(id)
            super(id.to_sym)
          end
        end

        module InstanceMethods
          def requires_redmine_plugin(id, arg, defer = true)
            if defer
              self.class.pluginloader_requirements << [self.id, id.to_sym, arg]
            else
              super(id.to_sym, arg)
            end
          end
        end
      end

      module Configuration
        module ClassMethods
          # HACK: We hijack Redmine::Plugin.mirror_assets to inject our dependency
          #       check after all plugins are loaded. For this to work, we need to
          #       make sure 'mirror_plugins_assets_on_startup' is enabled, so
          #       mirror_assets gets called in the redmine initializer code.
          def [](name)
            if Redmine::Plugin.pluginloader_is_startup
              return true if name == 'mirror_plugins_assets_on_startup'
            end
            super(name)
          end
        end
      end

      Redmine::Plugin.prepend Plugin::InstanceMethods
      Redmine::Plugin.singleton_class.prepend Plugin::ClassMethods
      Redmine::Configuration.singleton_class.prepend Configuration::ClassMethods
    end
  end
end
