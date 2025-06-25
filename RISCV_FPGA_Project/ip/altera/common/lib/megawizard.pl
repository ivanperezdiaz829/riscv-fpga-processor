#!/usr/bin/perl

# Can not use strict.pm, not included with Windows copy of perl under QUARTUS_BINDIR
#use strict;

my $check_exit_code = 0;

# +----------------------------------------------
# | This Perl script is a launch wrapper for the
# | Java program, sopceditor. In general it
# | constructs an appropriate classpath and passes
# | the command-line arguments through.
# |
# | This script will be launched by the main
# | sopc_builder script, which can also launch the
# | legacy sopc_builder application. If we put command
# | line help into the script, it should come from the
# | other "sopc_builder" script.
# |
# | It also discerns a few environment variables.
# |
# | ex:set expandtab:
# | ex:set tabstop=4:


sub isWin {
    return ($^O =~ /win/i);
}

sub getClasspathSeparator {
    return (isWin() ? ";" : ":");
}

# +------------------------
# | return an appended list of all the
# | jar files found in some directory
# |
sub appendJars {
    my $path = shift;

    opendir(my $DIR,$path);
    my @files = readdir($DIR);
    closedir($DIR);

    my @jars = 
        map  { "$path/$_" }       # Add the path in
        grep { !/^jmwizc.jar/i  } # And not jmwizc
        grep { !/^jwizman.jar/i } # But not jwizman
        grep {  /\.jar$/i       } # Only jars
        @files;

    return join(getClasspathSeparator(), @jars);
}


sub getPlatformBaseDir {
	my $jre_64 = shift;

    # We can't use the QUARTUS_BINDIR environment variable here
    # because we need to return the dir containing the binaries whose bitness
    # match the '$jre_64' argument
    # This ensures that the entry prepened to PATH/LD_LIBRARY_PATH by this script
    # matches the bitness if the jre used
    # This is neccessary because many java megawizards will use a JNI interface
    # to load Quartus libraries, and the bitness of the JRE must match the bitness of
    # the libaries, which are found by searching PATH/LD_LIBRARY_PATH

    # So because of all this, we will use QUARTUS_ROOTDIR and then determine
    # the binaries subdir ourselves

    my($qrd) = $ENV{QUARTUS_ROOTDIR};

    my($bindirname) = isWin() ? "bin" : "linux";
    if ($jre_64)
    {
        # If we're doing 64-bit jre, must use 64-bit binary dir
        $bindirname .= '64';
    }

    if ($qrd !~ m!/$!)
    {
        $qrd .= "/";
    }
    my($bindir) = "$qrd$bindirname";

    return $bindir;
}


sub getJavaExecutable {
    my $is_silent_mode = shift;
    my $jre_64         = shift;

	my $platform_dir = getPlatformBaseDir($jre_64);
    my $jredirname   = $jre_64 ? "jre64" : "jre";
    my $jredir       = "$platform_dir/$jredirname";

    if (! $jre_64 && ! -d $jredir)
    {
        # if we want the 32-bit JRE & '$jredir' doesn't exist, try getting
        # the 32-bit JRE that exists in the 64-bit Quartus directory
        # This should only be the case in a "64-bit only" build where the
        # 32-bit Quartus directory is never created
        
        my $platform_dir_64 = getPlatformBaseDir(1);
        my $jredir_64 = "$platform_dir_64/$jredirname";
        if ( -d $jredir_64 )
        {
            $jredir = $jredir_64;
        }
    }

    my $exe          = "java";
    if (isWin()) {
		$exe .= 'w' unless $is_silent_mode;
        $exe .= '.exe';
    }

	my $java = "$jredir/bin/$exe";

	if (!-x $java) {
		die "Error: Required Java exectuble '$java' does not exist";
	}

    return $java;
}

sub setup_env_vars {
    my $jre_64 = shift;

    my $sep      = getClasspathSeparator();

	# spr:343120 We need to make sure the PATH (LD_LIBRARY_PATH on Linux)
	# matches the version of the jre we are using, no matter what bitness
	# of Quartus called us. 
	# So even if the 64-bit version of Quartus called us, if we are using
	# the 32-bit JRE, we need to set the path var to have the 32-bit Quartus
	# dir first. 
	# If this isn't done, then Java code running in the 32-bit JRE will try to 
	# load the 64-bit versions of JNI code, causing a fatal error

	my $platform_dir = getPlatformBaseDir($jre_64);
    if(!isWin()) {
        # this ensures that any calls to quartus wrapper scripts from IP
        # will re-initialize the environment
		delete $ENV{QUARTUS_QENV};

		my $ldpath   = $ENV{LD_LIBRARY_PATH};
		$ENV{IPTB_LD_LIBRARY_PATH} = $ldpath;
		$ENV{LD_LIBRARY_PATH} = $platform_dir . $sep . $ldpath;
    } else {
		$ENV{PATH} = $platform_dir . $sep . $ENV{PATH};
	}

    # Case:13612 Set QUARTUS_BINDIR to match PATH/LD_LIBRARY_PATH to allow
    # for IP code to easily call Quartus executables
    $ENV{QUARTUS_BINDIR} = $platform_dir;
}


sub buildCommandLine {
    my $sep               = getClasspathSeparator();
    my $sopcLibDir        = $ENV{"QUARTUS_ROOTDIR"} . "/sopc_builder/model/lib";

	my $jre_64            = 0;
	my $is_silent_mode    = 0;
	my $megafunction_flow = undef;

    my @classpath_components;

	# Two-Pass scan: 
	#  - First pass is to pull out any arguments about which 
	#    this script needs to know 
	#
    foreach my $arg (@ARGV) { 
		if ($arg =~ /^-wizard_name:(.*)$/) {
			if (!defined($megafunction_flow)) {
				$megafunction_flow = 1;
			}
		}
		elsif ($arg =~ /^--classpath:(.*)$/) {
            my @components = split(/[,$sep]/,$1);

			if (!defined($megafunction_flow)) {
				$megafunction_flow = 0 if grep { /(.+)\/?\\?librarian\.jar/ } @components;
			}

			push @classpath_components, @components;
		}
        elsif ($arg =~ /^--check_exit_code$/) {
        	$check_exit_code = 1;	
        }
        elsif ($arg =~ /^-for64bit$/) {
			$jre_64 = 1;		  
		}
		elsif (   $arg =~ /^--?silent/ 
		       || $arg =~ /^--?script/  ) {
			$is_silent_mode = 1;
		}
    }
    
    if ($ENV{MWIZPL_64BIT} eq "1")
    {
        # Force use of 64-bit
        $jre_64 = 1;
    }

    # If the 32-bit platform dir does not exist, force the use of 64-bit
    if ( ! -d getPlatformBaseDir(0) )
    {
        $jre_64 = 1;
    }        

	#
   	#  - Second is to determine what we need to pass to the underlying 
	#    Java call, transforming as necessary
	#
	my @args_to_pass;

    foreach my $arg (@ARGV) { 
		next if ($arg =~ /^--classpath:(.*)$/);

		if ($arg =~ /^-projectpath(.+)$/) {
			# This case needs to come first, as there could be a colon 
			# in the project path value, which would get picked up by
			# later key/value patterns
        	$arg = "-projectpath=$1";	
        }
        elsif ($arg =~ /^-devicefamily([^:]+)$/) {
        	$arg = "-devicefamily=$1";	
        }
        elsif ($arg =~ /^-projectname([^:]+)$/) {
        	$arg = "-projectname=$1";	
        }
        elsif ($arg =~ /^([-]+[^:]+):(.*)$/) {
           $arg = "$1=$2";
        }
	
        push @args_to_pass, $arg; 
    }
    
	my $args = join(' ', map { qq{"$_"} } @args_to_pass);
    my $java = getJavaExecutable($is_silent_mode, $jre_64);

    setup_env_vars($jre_64);

    my $command = qq{"$java" -Xms64m -Xmx1g};

    if($megafunction_flow) {
     	my $classpath = join($sep, @classpath_components,	"$sopcLibDir/jmwizc.jar", appendJars($sopcLibDir));
        my $mainClass = "com.altera.sopceditor.app.megawizard.MegaWizardLauncher";
        $command = qq{$command -classpath "$classpath" $mainClass $args};
    }
    else {
        $command = qq{$command -jar "$sopcLibDir/com.altera.iplauncher.jar" $args};
    }

    return $command;
}


sub main {
    my $command = buildCommandLine();
    if ($ENV{MWIZPL_VERBOSE})
    {
        if (isWin())
        {
            print("PATH=$ENV{PATH}\n");
        }
        else
        {
            print("LD_LIBRARY_PATH=$ENV{LD_LIBRARY_PATH}\n")
        }
        print("$command\n");
    }
    my $result  = system($command);

    # our exit code is in bits 8-15, discard bits 0-7, and sign-correct it.
    $result >>= 8;
    $result = -(256-$result) if ($result > 127);

    if($check_exit_code eq 1) {
		$result = ($result == -1) ? 1
		        :                   0;
    }

    exit $result;
}

main();

