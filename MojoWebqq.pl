#!/usr/bin/env perl
use Mojo::Webqq;
my ($qq,$host,$port,$post_api);
$qq=2362526227;
$host="0.0.0.0";
$port=5999;


my $client = Mojo::Webqq->new(qq=>$qq);

#$client->load("PostQRcode",data=>{
#        smtp    =>  'smtp.163.com',
#        port    =>  '25',
#        from    =>  'zabbix',
#        to      =>  'wenxilu',
#        user    =>  'xilu_wen@163.com',
#        pass    =>  '668706wenjiahao',
#    });

$client->login();
#$client->load("ShowMsg");
$client->load("Openqq",data=>{listen=>[{host=>$host,port=>$port}], post_api=>$post_api});
$client->run();
