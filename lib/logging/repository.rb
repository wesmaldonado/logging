
require 'singleton'

module Logging

  # The Repository is a hash that stores references to all Loggers
  # that have been created. It provides methods to determine parent/child
  # relationships between Loggers and to retrieve Loggers from the hash.
  #
  class Repository
    include Singleton

    PATH_DELIMITER = '::'  # :nodoc:

    # nodoc:
    #
    # This is a singleton class -- use the +instance+ method to obtain the
    # +Repository+ instance.
    #
    def initialize
      @masters = []
      @h = {:root => ::Logging::RootLogger.new}

      # configures the internal logger which is disabled by default
      logger = ::Logging::Logger.allocate
      logger._setup(
          to_key(::Logging),
          :parent   => @h[:root],
          :additive => false,
          :level    => ::Logging::LEVELS.length   # turns this logger off
      )
      @h[logger.name] = logger
    end

    # call-seq:
    #    instance[name]
    #
    # Returns the +Logger+ named _name_.
    #
    # When _name_ is a +String+ or a +Symbol+ it will be used "as is" to
    # retrieve the logger. When _name_ is a +Class+ the class name will be
    # used to retrieve the logger. When _name_ is an object the name of the
    # object's class will be used to retrieve the logger.
    #
    # Example:
    #
    #   repo = Repository.instance
    #   obj = MyClass.new
    #
    #   log1 = repo[obj]
    #   log2 = repo[MyClass]
    #   log3 = repo['MyClass']
    #
    #   log1.object_id == log2.object_id         # => true
    #   log2.object_id == log3.object_id         # => true
    #
    def []( key ) @h[to_key(key)] end

    # call-seq:
    #    instance[name] = logger
    #
    # Stores the _logger_ under the given _name_.
    #
    # When _name_ is a +String+ or a +Symbol+ it will be used "as is" to
    # store the logger. When _name_ is a +Class+ the class name will be
    # used to store the logger. When _name_ is an object the name of the
    # object's class will be used to store the logger.
    #
    def []=( key, val ) @h[to_key(key)] = val end

    # call-seq:
    #    fetch( name )
    #
    # Returns the +Logger+ named _name_. An +IndexError+ will be raised if
    # the logger does not exist.
    #
    # When _name_ is a +String+ or a +Symbol+ it will be used "as is" to
    # retrieve the logger. When _name_ is a +Class+ the class name will be
    # used to retrieve the logger. When _name_ is an object the name of the
    # object's class will be used to retrieve the logger.
    #
    def fetch( key ) @h.fetch(to_key(key)) end

    # call-seq:
    #    has_logger?( name )
    #
    # Returns +true+ if the given logger exists in the repository. Returns
    # +false+ if this is not the case.
    #
    # When _name_ is a +String+ or a +Symbol+ it will be used "as is" to
    # retrieve the logger. When _name_ is a +Class+ the class name will be
    # used to retrieve the logger. When _name_ is an object the name of the
    # object's class will be used to retrieve the logger.
    #
    def has_logger?( key ) @h.has_key?(to_key(key)) end

    # call-seq:
    #    parent( key )
    #
    # Returns the parent logger for the logger identified by _key_ where
    # _key_ follows the same identification rules described in
    # <tt>Repository#[]</tt>. A parent is returned regardless of the
    # existence of the logger referenced by _key_.
    #
    # A note about parents -
    #
    # If you have a class A::B::C, then the parent of C is B, and the parent
    # of B is A. Parents are determined by namespace.
    #
    def parent( key )
      name = parent_name(to_key(key))
      return if name.nil?
      @h[name]
    end

    # call-seq:
    #    children( key )
    #
    # Returns an array of the children loggers for the logger identified by
    # _key_ where _key_ follows the same identification rules described in
    # +Repository#[]+. Children are returned regardless of the
    # existence of the logger referenced by _key_.
    #
    def children( parent )
      ary = []
      parent = to_key(parent)

      @h.each_pair do |child,logger|
        next if :root == child
        ary << logger if parent == parent_name(child)
      end
      return ary.sort
    end

    # call-seq:
    #    to_key( key )
    #
    # Takes the given _key_ and converts it into a form that can be used to
    # retrieve a logger from the +Repository+ hash.
    #
    # When _key_ is a +String+ or a +Symbol+ it will be returned "as is".
    # When _key_ is a +Class+ the class name will be returned. When _key_ is
    # an object the name of the object's class will be returned.
    #
    def to_key( key )
      case key
      when :root, 'root'; :root
      when String; key
      when Symbol; key.to_s
      when Module; key.logger_name
      when Object; key.class.logger_name
      end
    end

    # Returns the name of the parent for the logger identified by the given
    # _key_. If the _key_ is for the root logger, then +nil+ is returned.
    #
    def parent_name( key )
      return if :root == key

      a = key.split PATH_DELIMITER
      p = :root
      while a.slice!(-1) and !a.empty?
        k = a.join PATH_DELIMITER
        if @h.has_key? k then p = k; break end
      end
      p
    end

    # call-seq:
    #    add_master( 'First::Name', 'Second::Name', ... )
    #
    # Add the given logger names to the list of consolidation masters. All
    # classes in the given namespace(s) will use these loggers instead of
    # creating their own individual loggers.
    #
    def add_master( *args )
      args.map do |key|
        key = to_key(key)
        @masters << key unless @masters.include? key
        key
      end
    end

    # call-seq:
    #    master_for( key )
    #
    # Retruns the consolidation master name for the given _key_. If there is
    # no consolidation master, then +nil+ is returned.
    #
    def master_for( key )
      return if @masters.empty?
      key = to_key(key)

      loop do
        break key if @masters.include? key
        break nil if :root == key

        if index = key.rindex(PATH_DELIMITER)
          key = key.slice(0, index)
        else
          key = :root
        end
      end
    end

  end  # class Repository
end  # module Logging

# EOF
