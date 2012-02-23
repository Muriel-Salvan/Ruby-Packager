
require 'rdoc/rdoc'
require 'rdoc/generator'
require 'rdoc/generator/markup'

#
#  Muriel RDoc HTML Generator
#  
#  This generator has been copied from the wonderful work done by Darkfish.
#  Here are the changes made from it:
#  * Generate anchors from method names, therefore links can be persistent even if methods' order is changed when generating several times.
#  * Changed a little bit of CSS:
#    * some users were complaining of colors not so readable.
#    * margins were all reduced to 0, making impossible to tabulate hierarchical lists in comments.
#  * Added raw content display in every file page display (in popup or main windows).
#  * Added the possibility to add some project's metadata (Name, URL, links...) to each generated page.
#
#  Changes made by Muriel Salvan (muriel@x-aeon.com)
#  
class RDoc::Generator::Muriel < RDoc::Generator::Darkfish

	RDoc::RDoc.add_generator( self )

  # The metadata, or nil if none
  #   map< Symbol, Object >
  attr_reader :metadata

	def initialize( options )
    super(options)

    if (defined?($ProjectInfo) != nil)
      @metadata = $ProjectInfo
    else
      @metadata = nil
    end

		template = @options.template || 'muriel'

		template_dir = $LOAD_PATH.map do |path|
			File.join path, GENERATOR_DIR, 'template', template
		end.find do |dir|
			File.directory? dir
		end

		raise RDoc::Error, "could not find template #{template.inspect}" unless
			template_dir

		@template_dir = Pathname.new File.expand_path(template_dir)

	end

end # Roc::Generator::Muriel
