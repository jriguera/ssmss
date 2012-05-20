package Output;
#
#    This module is part of ssmss, a linux perl script for send short messages 
#    to gsm phones.
#
#    Copyright (C) Enero 2003 José Riguera <j.riguera@gmx.net>
#
#    This module is free software; you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation; either version 2 of the License, or
#    (at your option) any later version.
#
#    This module is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this module; if not, write to the Free Software
#    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
#
#
#    Redistribution and use in source and binary forms, with or without
#    modification, are permitted provided that the following conditions are met:
#    1. Redistributions of source code must retain the above copyright
#       notice, this list of conditions and the following disclaimer.
#    2. Redistributions in binary form must reproduce the above copyright
#       notice, this list of conditions and the following disclaimer in the
#       documentation and/or other materials provided with the distribution.
#    3. Neither the name of José Riguera nor the names of his
#       contributors may be used to endorse or promote products derived from
#       this software without specific prior written permission.
# 
require 5.005;
use strict;
use warnings;


BEGIN {
    use Exporter ();
    use vars qw($VERSION @ISA @EXPORT);

    # set the version for version checking
    $VERSION     = 1.00;

    @ISA         = qw(Exporter);
    
    @EXPORT      = qw(&module_send_sms &module_init &module_load);
}

my $var_private=0;



sub module_send_sms
{
    my $sms = shift;            # text of sms
    my $phones = shift;         # array of destination phones
    my $configuration = shift;  # hash that shows the state of program
    my $statusbar = shift;      # statusbar
    my $context_id = shift;     # statusbar's context
    
    
    print "**** Module Output send (write)***\n\n";
    
    if (defined $statusbar)
    {
        print "First, look at statusbar (sleep 5 s)\n";

        $statusbar->pop ($context_id);
        $statusbar->push ($context_id, " HELO WORLD!        ¡HOLA MUNDO!");
        #$statusbar->push ($context_id, "123456789012345678901234567890123456789012345678901234567890123456789012345");
        while(Gtk->events_pending()) { Gtk->main_iteration(); }
        sleep 5;
    }

    print "Destination phones : @$phones\n\n";
    my $numbers = join ("&numero=", @$phones);
    print "Sms text:\n";
    print "***\n";
    print "$sms\n";
    print "***\n\n";    
    print "Hash configuration :\n";    
    print "***\n";    
    while ((my $key, my $value) = each (%$configuration))
    {
        print "\t$key=$$configuration{$key}\n";
    }
    print "***\n\n";        
    
    if (defined $statusbar)
    {
        print "Look at statusbar again\n";

        $statusbar->pop ($context_id);
        $statusbar->push ($context_id, " OK: SMS write output ok");
        while(Gtk->events_pending()) { Gtk->main_iteration(); }
        sleep 5;
    }
    print "Private var: $var_private\n\n";
    $var_private++;
    print "The end\n\n\n";
    
    # if returns 1, program updates statusbar (operation ok)
    # if returns -1, program updates statusbar (operation failed)
    # if returns 0, program not update statusbar    
    return 0;
}



sub module_init 
{
    my $conf = shift;
    my $info = shift;


    print "**** Module Output init        ***\n";

    $$info{'length'} = 100;
    $$info{'name'} = "output";


    # You can set this keys of 1st hash (parameter 1st of 'module_init' function 

    $$conf{'login'} = "enabled";
    $$conf{'password'} = "enabled";
    $$conf{'mail'} = "enbled";
    $$conf{'anonymoussms'} = "enabled";
    $$conf{'confirmsms'} = "enabled";
    $$conf{'longsms'} = "enabled";    
    $$conf{'localaddressbook'} = "enabled";
    $$conf{'remoteaddressbook'} = "enabled";
    
    $var_private++;
    
    # For disabled, you can omit the key or set 'disabled'

    return 1;
}



sub module_load
{
    my %module_info;


    # print "**** Loading 'Output' module   ***\n";

    $module_info{'name'} = "Output";
    $module_info{'server'} = "output";
    $module_info{'author'} = "José Riguera";
    $module_info{'date'} = "2002";
    $module_info{'mail'} = "j.riguera\@gms.net";
    $module_info{"license"} = "GPL";
    $module_info{"version"} = "1.00";
    $module_info{"description"} = "This is a sample module\nEste es un modulo de ejemplo";
    
    $var_private++;

    return %module_info;
}



# module clean-up code here (global destructor)

END { }

# don't forget to return a true value from the file
return 1;

