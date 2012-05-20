package Amena;
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
use LWP::UserAgent;
use HTTP::Headers;
use HTTP::Cookies;
use HTTP::Request::Common qw(POST), qw(GET), qw(HEAD);



BEGIN {
    use Exporter ();
    use vars qw($VERSION @ISA @EXPORT);

    # set the version for version checking
    $VERSION     = 1.00;

    @ISA         = qw(Exporter);
    
    @EXPORT      = qw(&module_send_sms &module_init &module_load);
}



my $user_agent;
my $cookies;
my $numero_sms = 0;



# Subrutinas necesarias por el modulo. (Funciones privadas, no pueden ser exportadas)

my $http_header = sub
{
    my $http = shift;
    
    $http->HTTP::Headers::header (
           User_Agent     => "Mozilla/8.0",
           Host           => 'www.amena.com',
           Accept         => 'text/html, text/plain, image/*' 
    );
};


my $http_debug = sub
{
    my $request = shift;
    my $response = shift;
    my $cookiess = shift;
    
    print $request->HTTP::Request::as_string ();
    print $response->HTTP::Response::as_string ();
    print $cookiess->HTTP::Cookies::as_string ();
};


my $http_conect = sub
{
    my $login = shift;
    my $pass = shift;
    my $statusbar = shift;
    my $context_id = shift;
    
    
    
    my $request;
    my $response;
    
    if (defined $statusbar)
    {
        $statusbar->pop ($context_id);
        $statusbar->push ($context_id, " Enviando SMS: #*#*#*#*#*#*");
        while(Gtk->events_pending()) { Gtk->main_iteration(); }
    }
    else
    {
        print ". ";
    }
    
    $request = POST 'http://www.amena.com/sms_login', [
                                                       usu   => $login,
                                                       clave => $pass,
                                                       url   => '/login_y_password/sms_login2.html'
                                                      ];
    &$http_header ($request);
    $response = $user_agent->request ($request);
    return (-1) if ($response->is_error);
    $cookies->extract_cookies ($response);
    
    #&$http_debug($request, $response, $cookies);
    if (defined $statusbar)
    {
        $statusbar->pop ($context_id);
        $statusbar->push ($context_id, " Enviando SMS: #*#*#*#*#*#*#*#*#*#*#*#*");
        while(Gtk->events_pending()) { Gtk->main_iteration(); }        
    }
    else
    {
        print ". ";
    }    
    
    $request = HEAD "http://www.amena.com/smspremium/index.html?user=$login";
    &$http_header ($request);
    $request->referer ('http://www.amena.com/login_y_password/sms_login1.html');
    $request->header (Pragma => 'no-cache');

    $cookies->add_cookie_header ($request);
    
    $response = $user_agent->request ($request);
    return (-1) if ($response->is_error);    
    $cookies->extract_cookies ($response);
    
    #&$http_debug($request, $response, $cookies);
    if (defined $statusbar)
    {
        $statusbar->pop ($context_id);
        $statusbar->push ($context_id, " Enviando SMS: #*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*");
        while(Gtk->events_pending()) { Gtk->main_iteration(); }        
    }
    else
    {
        print ". ";
    }

    $request = HEAD "http://www.amena.com/smspremium/page.html?user=$login";
    &$http_header ($request);
    $request->referer ("http://www.amena.com/smspremium/index.html?user=$login");
    $request->header (Pragma => 'no-cache');

    $cookies->set_cookie (0, "ref_cookie", "ingles.amena.com:8881,ingles.amena.com,integracion.amena.com,eresmas.amena.com,am10.mad.eresmas.com,www.amena.com,deve.amena.com,tsamena.amena.com,amenaok.eresmas.com,mail.amenate.com,sms.amenate.com,www.amenapolis.com,amenapolisbs.com,beatles.cselt.it,finedelcookie", "/", "www.amena.com", undef, 0, 0, 300, 0, undef);
    $cookies->add_cookie_header ($request);
    $response = $user_agent->request ($request);
    return (-1) if ($response->is_error);        
    $cookies->extract_cookies ($response);

    if (defined $statusbar)
    {
        $statusbar->pop ($context_id);
        $statusbar->push ($context_id, " Enviando SMS: #*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*");        
        while(Gtk->events_pending()) { Gtk->main_iteration(); }        
    }
    else
    {
        print ". ";
    }

    #&$http_debug($request, $response, $cookies);
    return 1;
};



# Funciones que exporta este modulo

sub module_send_sms
{
    my $sms = shift;            # text of sms
    my $phones = shift;         # array of destination phones
    my $configuration = shift;  # hash that shows the state of program
    my $statusbar = shift;      # statusbar
    my $context_id = shift;     # statusbar's context


    
    if (defined ($statusbar))
    {
        $statusbar->pop ($context_id);
        $statusbar->push ($context_id, " Enviando SMS: ");
        while(Gtk->events_pending()) { Gtk->main_iteration(); }
    }
    else
    {
        $|=1;
        print "Enviando SMS : . ";
    }

    my $login = $$configuration{'login'};
    my $pass = $$configuration{'password'};

    if ( (!defined ($user_agent)) || ($numero_sms < 1) )
    {
        $user_agent = LWP::UserAgent->new (keep_alive => 1, timeout => 240);
        $cookies = HTTP::Cookies->new (hide_cookie2 => 1);
        $numero_sms = 0;
        if (&$http_conect ($login, $pass, $statusbar, $context_id) == -1)
        {
            if (defined ($statusbar))
            {
                $statusbar->pop ($context_id);
                $statusbar->push ($context_id, " Enviando SMS: ERROR conectando con el servidor. Mensaje NO ENVIADO");
                while(Gtk->events_pending()) { Gtk->main_iteration(); }
                sleep 3;
            }
            else
            {
                print ". ";
            }            
            return 0;
        }
    }
    elsif (defined ($statusbar))
    {
        $statusbar->pop ($context_id);
        $statusbar->push ($context_id, " Enviando SMS: #*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*");
        while(Gtk->events_pending()) { Gtk->main_iteration(); }        
    }
    else
    {
        print ". ";
    }

    my $numeros = join ("&numero=", @$phones);
    my $request = POST 'http://www.amena.com/smspremium/sendsms.html', [ msg => "$sms" ];
    $request->HTTP::Request::as_string() =~ m/msg=(.*)/;
    my $parametros = "from=$login&cook=true&senddate=&smspremiumcount=20&smspremiumdata=11579&remindercount=20&reminderdata=11580&maxmessaggexday=20&input_numero=";
    $parametros .= "&numero=$numeros&msg=$1";
    $parametros .= '&firma=on' if ($$configuration{'anonymoussms'} eq 'off');
    $parametros .= '&ricevuta=on' if ($$configuration{'confirmsms'} eq 'on');
    $parametros .= '&largemessage=on' if ($$configuration{'longsms'} eq 'on');
    $parametros .= '&combocategoria=&comboabreviatura=ABREVIATURAS';
    $request = POST 'http://www.amena.com/smspremium/sendsms.html';
    &$http_header ($request);
    $request->content_type('application/x-www-form-urlencoded');
    $request->content ("$parametros");
    $request->content_length(length($parametros));
    $request->referer ("http://www.amena.com/smspremium/page.html?user=$login");
    $cookies->add_cookie_header ($request);

    my $response = $user_agent->request ($request);
    #&$http_debug($request, $response, $cookies);
    
    $numero_sms++;
    
    if ($response->is_success)
    {
        if (defined ($statusbar))
        {
            $statusbar->pop ($context_id);
            $statusbar->push ($context_id, " Enviando SMS: #*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*    OK");
            while(Gtk->events_pending()) { Gtk->main_iteration(); }
            sleep 1;
        }
        else
        {
            print "OK\n";
        }   
        return 0;
    }
    if (defined ($statusbar))
    {
        $statusbar->pop ($context_id);
        $statusbar->push ($context_id, " Enviando SMS: #*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#* ERROR CONFIRMACION");
        while(Gtk->events_pending()) { Gtk->main_iteration(); }
        sleep 2;
    }
    else
    {
        print "ERROR DE CONFIRMACION DE ENVIO\n";
    }
    $|=0;
    return 0;
}



sub module_init
{
    my $conf = shift;
    my $info = shift;


    $$info{'length'} = 132;
    $$info{'name'} = "Amena";

    $$conf{'login'} = "enabled";
    $$conf{'password'} = "enabled";
    $$conf{'mail'} = "enbled";
    $$conf{'anonymoussms'} = "enabled";
    $$conf{'confirmsms'} = "enabled";
    $$conf{'longsms'} = "enabled";    

    return 1;
}



sub module_load
{
    my %module_info;


    $module_info{'name'} = "Amena";
    $module_info{'server'} = "amena.com";
    $module_info{'author'} = "José Riguera";
    $module_info{'date'} = "2002";
    $module_info{'mail'} = "j.riguera\@gms.net";
    $module_info{"license"} = "GPL";
    $module_info{"version"} = "0.20";
    $module_info{"description"} = "El modulo Amena accede y envia los sms a traves de www.amena.com. Es necesario ser cliente de Amena para poder usar el servicio. Las confirmaciones se reciben en 'telefono'\@amena.com";

    return %module_info;
}



# module clean-up code here (global destructor)

END { }


# don't forget to return a true value from the file

return 1;

