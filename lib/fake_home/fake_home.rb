module FakeHome
  require 'tempfile'
  require 'tmpdir'

  # Will be thrown if your HOME isn't prepared for restoring.
  class PreparationError < StandardError; end

  # It manipulate and restores your environment variable $HOME. I recommend to use it in your test suite.
  #
  # More examples are in each method. Take a look!
  #
  # @example
  #   include FakeHome
  #
  #   Home.new("/tmp/fake_home").fake_home do |new_home|
  #     new_home == ENV["HOME"]
  #   end
  class Home
    # Default options for contructor
    DEFAULT_OPTIONS = {prefix: "test", suffix: "home"}

    # Prefix are the first few characters in the generated temporary directory.
    attr_reader :prefix

    # Suffix are the last few characters in the generated temporary directory.
    attr_reader :suffix

    # Stores your original HOME after preparation.
    attr_reader :original_home

    # Creates a new Home. If no explicit path is set, it will be generated a temporary one in your `/tmp` (see `@prepare`).
    #
    # @example
    #   Home.new("/tmp/fake_home")
    # @example
    #   Home.new(prefix: "new_prefix").prefix #=> "new_prefix"
    # @example
    #   Home.new(suffix: "new_suffix").suffix #=> "new_suffix"
    # @example
    #   Home.new("/tmp/fake_home", suffix: "new_suffix")
    def initialize(*args)
      @fake_home = args.first if args.first.is_a? String
      options = extract_init_options(args)
      options = DEFAULT_OPTIONS.merge(options)
      @prefix, @suffix = options[:prefix], options[:suffix]
    end

    # Prepares your new HOME. Old HOME will be saved and can be restored.
    #
    # @example
    #   Home.new("/tmp/fake_home").prepare #=> "/tmp/fake_home"
    #   Home.new.prepare #=> "/tmp/test_20130311-6400-1ku43dk_home"
    #
    # @example
    #   home = Home.new("/tmp/fake_home")
    #   ENV["HOME"] #=> "/home/username"
    #   home.prepare
    #   ENV["HOME"] #=> "/tmp/fake_home"
    #
    # @return new home path
    def prepare
      @original_home = ENV["HOME"]
      @fake_home = mkdir
      ENV["HOME"] = @fake_home
    end

    # Does your fake HOME exist?
    #
    # @example
    #   home = Home.new
    #   home.prepared? #=> false
    #   home.prepare
    #   home.prepared? #=> true
    def prepared?
      ENV["HOME"] == @fake_home
    end

    # Restores your original HOME.
    #
    # @raise PreparationError if not prepared
    #
    # @example
    #   home = Home.new("/tmp/fake_home")
    #   home.prepare
    #   ENV["HOME"] #=> "/tmp/fake_home"
    #   home.restore
    #   ENV["HOME"] #=> "/home/username"
    #
    # @return original home path
    def restore
      raise PreparationError, "You have to prepare first." unless prepared?

      FileUtils.rm_rf @fake_home
      ENV["HOME"] = @original_home
    end

    # Does your orginial HOME exist?
    #
    # @example
    #   home = Home.new
    #   home.prepare
    #   home.restored? #=> false
    #   home.restore
    #   home.restored? #=> true
    def restored?
      ENV["HOME"] == @original_home
    end

    # Gets your fake HOME path. If a block is set, you can work in it with your fake home. Everything outside will be
    # your original home.
    #
    # @example
    #   home = Home.new("/tmp/fake_home")
    #   ENV["HOME"] #=> "/home/username"
    #   home.fake_home do |home|
    #     ENV["HOME"] #=> "/tmp/fake_home"
    #   end
    #   ENV["HOME"] #=> "/home/username"
    #
    # @return path of your fake home
    def fake_home
      if block_given?
        prepare
        yield @fake_home
        restore
      end
      @fake_home
    end

    private

    def extract_init_options(args)
      last = args.last
      if args && last && last.is_a?(Hash)
        options = last
      end
      options ||= {}
    end

    def mkdir
      if @fake_home
        FileUtils.mkdir_p(@fake_home)
        @fake_home
      else
        Dir.mktmpdir([@prefix+"_", "_"+@suffix], Dir.tmpdir)
      end
    end
  end
end
