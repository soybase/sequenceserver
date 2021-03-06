require 'find'
require 'forwardable'

module SequenceServer
  # Smart `makeblastdb` wrapper: recursively scans database directory determining
  # which files need to be formatted or re-formatted.
  #
  # Example usage:
  #
  #   makeblastdb = MAKEBLASTDB.new(database_dir)
  #   makeblastdb.scan && makeblastdb.run
  #
  class MAKEBLASTDB
    # We want V5 databases created using -parse_seqids for proper function of
    # SequenceServer. This means each database should be comprised of at least 9
    # files with the following extensions. Databases created by us will have two
    # additional files with the extensions nhd and nhi, or phd and phi, due to
    # the use of -hash_index option. Finally, multipart databases will have one
    # additional file with the extension nal or pal.
    REQUIRED_EXTENSIONS = {
      'nucleotide' => %w{ndb nhr nin nog nos not nsq ntf nto}.freeze,
      'protein' => %w{pdb phr pin pog pos pot psq ptf pto}.freeze
    }

    extend Forwardable

    def_delegators SequenceServer, :config, :sys

    def initialize(database_dir)
      @database_dir = database_dir
    end

    attr_reader :database_dir

    # Scans the database directory to determine which FASTA files require
    # formatting or re-formatting.
    #
    # Returns `true` if there are files to (re-)format, `false` otherwise.
    def scan
      # We need to know the list of formatted FASTAs as reported by blastdbcmd
      # first. This is required to determine both unformatted FASTAs and those
      # that require reformatting.
      @formatted_fastas = []
      determine_formatted_fastas

      # Now determine FASTA files that are unformatted or require reformatting.
      @fastas_to_format = []
      determine_unformatted_fastas
      determine_fastas_to_reformat

      # Return true if there are files to be (re-)formatted or false otherwise.
      !@fastas_to_format.empty?
    end

    # Runs makeblastdb on each file in `@fastas_to_format`. Will do nothing
    # unless `#scan` has been run before.
    def run
      return unless @fastas_to_format || @fastas_to_format.empty?
      @fastas_to_format.each do |path, title, type|
        make_blast_database(path, title, type)
      end
    end

    private

    # Determines which FASTA files in the database directory are already
    # formatted. Adds to @formatted_fastas.
    def determine_formatted_fastas
      blastdbcmd.each_line do |line|
        path, title, type = line.split('	')
        next if multipart_database_name?(path)
        @formatted_fastas << [path, title, type.strip.downcase]
      end
    end

    # Determines which FASTA files in the database directory require
    # reformatting. Adds to @fastas_to_format.
    def determine_fastas_to_reformat
      @formatted_fastas.each do |path, title, type|
        required_extensions = REQUIRED_EXTENSIONS[type]
        exts = Dir["#{path}.*"].map { |p| p.split('.').last }.sort
        next if (exts & required_extensions) == required_extensions

        @fastas_to_format << [path, title, type]
      end
    end

    # Determines which FASTA files in the database directory are
    # unformatted. Adds to @fastas_to_format.
    def determine_unformatted_fastas
      Find.find(database_dir) do |path|
        next if File.directory?(path)
        next unless probably_fasta?(path)
        next if @formatted_fastas.any? { |f| f[0] == path }

        @fastas_to_format << [path,
          make_db_title(File.basename(path)),
          guess_sequence_type_in_fasta(path)]
      end
    end

    # Runs `blastdbcmd` to determine formatted FASTA files in the database
    # directory. Returns the output of `blastdbcmd`. This method is called
    # by `determine_formatted_fastas`.
    def blastdbcmd
      cmd = "blastdbcmd -recursive -list #{database_dir}" \
            ' -list_outfmt "%f	%t	%p"'
      out, _ = sys(cmd, path: config[:bin])
      out
    end

    # Create BLAST database, given FASTA file and sequence type in FASTA file.
    def make_blast_database(file, title, type)
      return unless make_blast_database? file, type
      title = confirm_database_title(title)
      taxid = fetch_tax_id
      _make_blast_database(file, type, title, taxid)
    end

    def _make_blast_database(file, type, title, taxid)
      extract_fasta(file) unless File.exist?(file)
      cmd = "makeblastdb -parse_seqids -hash_index -in #{file} " \
            "-dbtype #{type.to_s.slice(0, 4)} -title '#{title}'" \
            " -taxid #{taxid}"
      out, err = sys(cmd, path: config[:bin])
      puts out.strip
      puts err.strip
    rescue CommandFailed => e
      puts <<~MSG
        Could not create BLAST database for: #{file}
        Tried: #{cmd}
        stdout: #{e.stdout}
        stderr: #{e.stderr}
      MSG
      exit!
    end

    # Show file path and guessed sequence type to the user and obtain a y/n
    # response.
    #
    # Returns true if the user entered anything but 'n' or 'N'.
    def make_blast_database?(file, type)
      puts
      puts
      puts "FASTA file to format/reformat: #{file}"
      puts "FASTA type: #{type}"
      print 'Proceed? [y/n] (Default: y): '
      response = STDIN.gets.to_s.strip
      !response.match(/n/i)
    end

    # Show the database title that we are going to use to the user for
    # confirmation.
    #
    # Returns user input if any. Auto-determined title otherwise.
    def confirm_database_title(default)
      print "Enter a database title or will use '#{default}': "
      from_user = STDIN.gets.to_s.strip
      from_user.empty? && default || from_user
    end

    # Get taxid from the user. Returns user input or 0.
    #
    # Using 0 as taxid is equivalent to not setting taxid for the database
    # that will be created.
    def fetch_tax_id
      default = 0
      print 'Enter taxid (optional): '
      user_response = STDIN.gets.strip
      user_response.empty? && default || Integer(user_response)
    rescue
      puts 'taxid should be a number'
      retry
    end

    # Extract FASTA file from BLAST database.
    #
    # Invoked while reformatting a BLAST database if the corresponding
    # FASTA file does not exist.
    def extract_fasta(db)
      puts
      puts 'Extracting sequences ...'
      cmd = "blastdbcmd -entry all -db #{db}"
      sys(cmd, stdout: db, path: config[:bin])
    rescue CommandFailed => e
      puts <<~MSG
        Could not extract sequences from: #{db}
        Tried: #{cmd}
        stdout: #{e.stdout}
        stderr: #{e.stderr}
      MSG
      exit!
    end

    # Returns true if the database name appears to be a multi-part database
    # name.
    def multipart_database_name?(db_name)
      Database.multipart_database_name? db_name
    end

    # Returns true if first character of the file is '>'.
    def probably_fasta?(file)
      File.read(file, 1) == '>'
    end

    # Suggests improved titles when generating database names from files
    # for improved apperance and readability in web interface.
    # For example:
    # Cobs1.4.proteins.fasta -> Cobs 1.4 proteins
    # S_invicta.xx.2.5.small.nucl.fa -> S invicta xx 2.5 small nucl
    def make_db_title(db_name)
      db_name.tr!('"', "'")
      # removes .fasta like extension names
      db_name.gsub!(File.extname(db_name), '')
      # replaces _ with ' ',
      db_name.gsub!(/(_)/, ' ')
      # replaces '.' with ' ' when no numbers are on either side,
      db_name.gsub!(/(\D)\.(?=\D)/, '\1 ')
      # preserves version numbers
      db_name.gsub!(/\W*(\d+([.-]\d+)+)\W*/, ' \1 ')
      db_name
    end

    # Guess whether FASTA file contains protein or nucleotide sequences by
    # sampling a few few characters of the file.
    def guess_sequence_type_in_fasta(file)
      sequences = sample_sequences(file)
      sequence_types = sequences.map { |seq| Sequence.guess_type(seq) }
      sequence_types = sequence_types.uniq.compact
      (sequence_types.length == 1) && sequence_types.first
    end

    # Read first 1,048,576 characters of the file, split the read text on
    # fasta def line pattern and return.
    #
    # If the given file is FASTA, returns Array of as many different
    # sequences in the portion of the file read. Returns the portion
    # of the file read wrapped in an Array otherwise.
    def sample_sequences(file)
      File.read(file, 1_048_576).split(/^>.+$/).delete_if(&:empty?)
    end
  end
end
