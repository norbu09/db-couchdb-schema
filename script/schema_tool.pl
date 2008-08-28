use DB::CouchDB::Schema;
use Getopt::Long;

my ($dump,$load,$file,$help,
    $database,$host,$port,$dsn);

my $opts = GetOptions ("dump" => \$dump,
                       "load" => \$load,
                       "file=s" => \$file,
                       "help"   => \$help,
                       "db=s"     => \$database,
                       "host=s"   => \$host,
                       "port=i"   => \$port);

sub useage {
    print "schema_tool.pl --help # print this useage", $/;
    print "schema_tool.pl --dump --file=<filename> # dump the schema to filename", $/;
    print "schema_tool.pl --load --file=<filename> # load the schema from the filename", $/;
}

if ( $help ) {
    useage();
    exit 0;
}

if ($database && $host) {
    my %dbargs = (db     => $database,
                  host   => $host);
    $dbargs{port} = $port
        if $port;
    my $db = DB::CouchDB::Schema->new(%dbargs);
    
    if ($dump && $file) {
        open my $fh, '>', $file or die $!;
        my $script = $db->dump();
        print $fh $script;
        close $fh;
        exit 0;
    } elsif ($load && $file) {
        open my $fh, $file or die $!;
        local $/;
        $script = <$fh>;
        print "loading schema: ", $/, $script;
        $db->load_schema_from_script($script);
        $db->push();
        close LFH;
        exit 0;
    } else {
        print "Did not understand options!!", $/;
        useage();
        exit 1;
    }
}