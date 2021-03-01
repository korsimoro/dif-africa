require_relative '../difasia.rb'
require_relative '../munger/index.rb'

module Jekyll
  module Commands
    class Munge < Command
      class << self
        def init_with_program(prog)
          prog.command(:munge) do |c|
            c.syntax      "build [options]"
            c.description "Combine the data"

            #add_build_options(c)
            # Adjust verbosity quickly
            c.option "verbose", "-V", "--verbose", "Print verbose output."

            c.action do |args, options|
              Jekyll.logger.adjust_verbosity(options)

              Jekyll.logger.info "Munge Data!"+args.inspect+":"+options.inspect

              options = configuration_from_options(options)
              site = Jekyll::Site.new(options)
              RecordPool.basedir = File.join(site.source,'..')

              begin
                munger = Munger.new(site)
                munger.munge()
              rescue => exception
                puts exception.backtrace
                raise # always reraise
              end

            end
          end
        end

      end
    end
  end
end
