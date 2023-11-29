#!/usr/bin/perl

$to = 'lioral@marvell.com';
$from = 'lioral@marvell.com';
$subject = 'Test Email';
$message = '<h1>This is test email sent by Perl Script</h1>';
 
open(MAIL, "|/usr/sbin/sendmail -t");
 
# Email Header
print MAIL "To: $to\n";
print MAIL "From: $from\n";
print MAIL "Subject: $subject\n";
print MAIL "Content-type: text/html\n\n";
# Email Body
print MAIL "$message\n";

close(MAIL);
print "Email Sent Successfully\n";
