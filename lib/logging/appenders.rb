
module Logging
  module Appenders

    # Register a new appender from outside the core logging appenders
    # Ex: You could replace the email appender factory with:
    #     Logging::Appenders.register_appender('Email')   
    def register_appender(klazz)
      module_eval %Q{
      def #{klazz.downcase}(*args)
        k = ::Logging::Appenders.const_get("#{klazz}")
        return k if args.empty?
        k.new(*args)
      end
      }
    end

    # Accessor / Factory for the Email appender.
    #
    def email( *args )
          return ::Logging::Appenders::Email if args.empty?
          ::Logging::Appenders::Email.new(*args)
    end
    
    # Accessor / Factory for the File appender.
    #
    def file( *args )
      return ::Logging::Appenders::File if args.empty?
      ::Logging::Appenders::File.new(*args)
    end

    # Accessor / Factory for the Growl appender.
    #
    def growl( *args )
      return ::Logging::Appenders::Growl if args.empty?
      ::Logging::Appenders::Growl.new(*args)
    end

    # Accessor / Factory for the IO appender.
    #
    def io( *args )
      return ::Logging::Appenders::IO if args.empty?
      ::Logging::Appenders::IO.new(*args)
    end

    # Accessor / Factory for the RollingFile appender.
    #
    def rolling_file( *args )
      return ::Logging::Appenders::RollingFile if args.empty?
      ::Logging::Appenders::RollingFile.new(*args)
    end

    # Accessor / Factory for the Stderr appender.
    #
    def stderr( *args )
      if args.empty?
        return self['stderr'] || ::Logging::Appenders::Stderr.new
      end
      ::Logging::Appenders::Stderr.new(*args)
    end

    # Accessor / Factory for the Stdout appender.
    #
    def stdout( *args )
      if args.empty?
        return self['stdout'] || ::Logging::Appenders::Stdout.new
      end
      ::Logging::Appenders::Stdout.new(*args)
    end

    # Accessor / Factory for the StringIo appender.
    #
    def string_io( *args )
      return ::Logging::Appenders::StringIo if args.empty?
      ::Logging::Appenders::StringIo.new(*args)
    end

  if HAVE_SYSLOG
    # Accessor / Factory for the Syslog appender.
    #
    def syslog( *args )
      return ::Logging::Appenders::Syslog if args.empty?
      ::Logging::Appenders::Syslog.new(*args)
    end
  end

    # call-seq:
    #    Appenders[name]
    #
    # Returns the appender instance stroed in the appender hash under the
    # key _name_, or +nil+ if no appender has been created using that name.
    #
    def []( name ) @appenders[name] end

    # call-seq:
    #    Appenders[name] = appender
    #
    # Stores the given _appender_ instance in the appender hash under the
    # key _name_.
    #
    def []=( name, value ) @appenders[name] = value end

    # call-seq:
    #    Appenders.remove( name )
    #
    # Removes the appender instance stored in the appender hash under the
    # key _name_.
    #
    def remove( name ) @appenders.delete(name) end

    # call-seq:
    #    each {|appender| block}
    #
    # Yield each appender to the _block_.
    #
    def each( &block )
      @appenders.values.each(&block)
      nil
    end

    extend self
    @appenders = Hash.new

  end  # module Appenders
end  # module Logging


%w[buffering io console email file growl rolling_file string_io syslog].
each do |fn|
  require ::Logging.libpath('logging', 'appenders', fn)
end

# EOF
