# A sample Guardfile
# More info at https://github.com/guard/guard#readme
require 'coach'
## Uncomment and set this to only include directories you want to watch
# directories %w(app lib config test spec features) \
#  .select{|d| Dir.exists?(d) ? d : UI.warning("Directory #{d} does not exist")}

## Note: if you are using the `directories` clause above and you are not
## watching the project directory ('.'), then you will want to move
## the Guardfile to a watched dir and symlink it back, e.g.
#
#  $ mkdir config
#  $ mv Guardfile config/
#  $ ln -s config/Guardfile .
#
# and, you'll have to watch "config/Guardfile" instead of "Guardfile"

# Add files and commands to this file, like the example:
#   watch(%r{file/path}) { `command(s)` }
#

coach = Coach::Advice.new
coach.run

guard :shell do
  watch(//) do |modified_files|
    puts "Modified files: #{modified_files}"
   # `tail #{modified_files[0]}`
    # Read in the bash environment, after an optional command.
    #   Returns Array of key/value pairs.

    coach.run





  end
end
