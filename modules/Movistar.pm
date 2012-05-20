package Movistar;
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
use Net::SMTP;



BEGIN {
    use Exporter ();
    use vars qw($VERSION @ISA @EXPORT);

    # set the version for version checking
    $VERSION     = 1.00;

    @ISA         = qw(Exporter);
    
    @EXPORT      = qw(&module_send_sms &module_init &module_load);
}


my $saludo = 'localhost.localdomain';
my $servidor = 'correo.movistar.net';
my $smtpmail = "localhost\@localdomain";
my $tiempo = 60;
my $debug = 1;



sub module_send_sms
{
    my $mensaje = shift;
    my $telefonos = shift;
    my $configuracion = shift;
    my $statusbar = shift;
    my $context_id = shift;


    my $smtp;
    
    if (defined $statusbar)
    {    
        $statusbar->pop ($context_id);
        $statusbar->push ($context_id, " Enviando mensaje ... ");
    }
    if ($smtp = (Net::SMTP->new ($servidor, Hello=>$saludo, Timeout=>$tiempo, Debug=>$debug)))
    {
        foreach (@$telefonos)
        {
            $smtp->mail($smtpmail);
            $smtp->to("$_\@$servidor");
            $smtp->data();
            $smtp->datasend("From: $$configuracion{'mail'}\n");
            $smtp->datasend("To: $_\@$servidor\n");
            $smtp->datasend("\n");
            $smtp->datasend($mensaje);
            $smtp->dataend();
        }
        $smtp->quit;
        if (defined $statusbar)
        {        
            $statusbar->pop ($context_id);
            $statusbar->push ($context_id, " OK: mensaje/s enviado correctamente");
        }
    }
    
    if (defined $statusbar)
    {
        $statusbar->pop ($context_id);
        $statusbar->push ($context_id, " ERROR: ¡¡¡ Mensaje no enviado !!! ");
        while(Gtk->events_pending()) { Gtk->main_iteration(); }
        sleep 2;
    }
    
    # Al retornar 0 se evita que el programa principal modifique la barra de estado:
    # Si se devuelve 1, el programa principal coloca en la barra de estado un mensaje
    # envio correcto.
    # Si se devuelve -1, el programa coloca un mensaje de error en la barra de estado.
    return 0;
}



sub module_init 
{
    my $configuracion = shift;
    my $module_info = shift;


    $$module_info{'length'} = 150;
    $$module_info{'name'} = "Movistar";

    $$configuracion{'mail'} = "enabled";

    return 1;
}



sub module_load
{
    my %module_info;


    $module_info{'name'} = "Movistar";
    $module_info{'server'} = $servidor;
    $module_info{'author'} = "José Riguera";
    $module_info{'date'} = "2002";
    $module_info{'mail'} = "j.riguera\@gmx.net";
    $module_info{"license"} = "GPL";
    $module_info{"version"} = "1.00";
    $module_info{"description"} = "Este módulo envia sms a teléfonos pertenecientes al operador Movistar, para ello usa una pasarela de e-mail a sms.";

    return %module_info;
}



END { }

# don't forget to return a true value from the file
1;

