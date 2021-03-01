require 'date'
require 'uuid'
require 'yaml'

class RuntimeSupport

  def warn(msg,&block)
    Jekyll.logger.warn(self.class.name,"\e[31m#{msg}\e[0m",&block)
  end
  def info(msg,&block)
    Jekyll.logger.info(self.class.name,"\e[32m#{msg}\e[0m",&block)
  end
  def debug(msg,&block)
    Jekyll.logger.debug(self.class.name,"\e[36m#{msg}\e[0m",&block)
  end


  def slugify(msg)
    msg.strip.gsub(' ', '-').gsub(/[^\w-]/, '')
  end

end
